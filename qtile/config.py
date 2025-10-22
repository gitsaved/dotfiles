# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import os
import threading
import time

import libqtile.resources
from libqtile import bar, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen, ScratchPad, DropDown
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from qtile_extras.layout.decorations import GradientBorder

mod = "mod4"
terminal = guess_terminal()

# Map commands to their wm_class when they differ
COMMAND_TO_WM_CLASS = {
    "wezterm": "org.wezfurlong.wezterm",
    "firefox": "Firefox",
    "code": "Code",
}

# Special spawn commands for apps that need env vars (X11 version - no Wayland vars)
COMMAND_SPAWN_OVERRIDE = {
    "firefox": "env GTK_USE_PORTAL=0 firefox",
}

def focus_or_open_app(qtile, command, match_by_name=None):
    """
    Focus existing window of the app in current group, or spawn new if none exists.
    If match_by_name is provided, match windows by name instead of wm_class.
    """
    current_group = qtile.current_screen.group

    # Look for existing window in current group
    for window in current_group.windows:
        try:
            if match_by_name:
                # Match by window name/title
                window_name = window.name or ""
                if match_by_name.lower() in window_name.lower():
                    current_group.focus(window)
                    return
            else:
                # Match by wm_class (default behavior)
                expected_wm_class = COMMAND_TO_WM_CLASS.get(command, command)
                wm_class = window.get_wm_class()
                if wm_class and (wm_class[0].lower() == expected_wm_class.lower() or wm_class[1].lower() == expected_wm_class.lower()):
                    current_group.focus(window)
                    return
        except:
            continue

    # No existing window found, spawn new one
    # Use override command if specified, otherwise use the command as-is
    spawn_command = COMMAND_SPAWN_OVERRIDE.get(command, command)
    qtile.spawn(spawn_command)

def window_to_prev_screen(qtile):
    """Move window to previous screen and follow focus"""
    if qtile.current_window:
        current_index = qtile.current_screen.index
        target_index = (current_index - 1) % len(qtile.screens)
        qtile.current_window.toscreen(target_index)
        qtile.focus_screen(target_index)
        screen = qtile.screens[target_index]
        qtile.core.warp_pointer(screen.x + screen.width // 2, screen.y + screen.height // 2)

def window_to_next_screen(qtile):
    """Move window to next screen and follow focus"""
    if qtile.current_window:
        current_index = qtile.current_screen.index
        target_index = (current_index + 1) % len(qtile.screens)
        qtile.current_window.toscreen(target_index)
        qtile.focus_screen(target_index)
        screen = qtile.screens[target_index]
        qtile.core.warp_pointer(screen.x + screen.width // 2, screen.y + screen.height // 2)

def get_screen_mapping(qtile):
    """
    Map logical screen positions (left=0, middle=1, right=2) to qtile screen indices.
    Sorts screens by x-coordinate to get left-to-right order.
    """
    screens_with_pos = [(i, qtile.screens[i].x) for i in range(len(qtile.screens))]
    screens_with_pos.sort(key=lambda x: x[1])  # Sort by x position
    return [screen_idx for screen_idx, _ in screens_with_pos]

def window_to_screen_with_mouse(qtile, logical_screen_num):
    """Move window to specific screen, follow focus and warp mouse"""
    if qtile.current_window:
        screen_mapping = get_screen_mapping(qtile)
        actual_screen_num = screen_mapping[logical_screen_num]
        qtile.current_window.toscreen(actual_screen_num)
        qtile.focus_screen(actual_screen_num)
        screen = qtile.screens[actual_screen_num]
        qtile.core.warp_pointer(screen.x + screen.width // 2, screen.y + screen.height // 2)

def focus_screen_with_mouse(qtile, logical_screen_num):
    """Focus screen and warp mouse"""
    screen_mapping = get_screen_mapping(qtile)
    actual_screen_num = screen_mapping[logical_screen_num]
    qtile.focus_screen(actual_screen_num)
    screen = qtile.screens[actual_screen_num]
    qtile.core.warp_pointer(screen.x + screen.width // 2, screen.y + screen.height // 2)

def focus_prev_screen_with_mouse(qtile):
    """Focus previous screen and warp mouse"""
    current_index = qtile.current_screen.index
    target_index = (current_index - 1) % len(qtile.screens)
    qtile.focus_screen(target_index)
    screen = qtile.screens[target_index]
    qtile.core.warp_pointer(screen.x + screen.width // 2, screen.y + screen.height // 2)

def focus_next_screen_with_mouse(qtile):
    """Focus next screen and warp mouse"""
    current_index = qtile.current_screen.index
    target_index = (current_index + 1) % len(qtile.screens)
    qtile.focus_screen(target_index)
    screen = qtile.screens[target_index]
    qtile.core.warp_pointer(screen.x + screen.width // 2, screen.y + screen.height // 2)

def lock_screen():
    """Lock the screen using i3lock"""
    qtile.spawn("i3lock -c 000000")

# Auto-lock timer variables
auto_lock_timer = None
last_activity_time = time.time()

def reset_auto_lock_timer():
    """Reset the auto-lock timer"""
    global auto_lock_timer, last_activity_time
    last_activity_time = time.time()

    if auto_lock_timer:
        auto_lock_timer.cancel()

    auto_lock_timer = threading.Timer(900.0, lock_screen)  # 15 minutes = 900 seconds
    auto_lock_timer.start()

def on_user_activity():
    """Called on user activity to reset auto-lock timer"""
    reset_auto_lock_timer()

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Window navigation - simplified for Max layout
    Key([mod], "j", lazy.group.next_window(), desc="Focus next window"),
    Key([mod], "k", lazy.group.prev_window(), desc="Focus previous window"),
    # Screen switching
    Key([mod], "h", lazy.function(focus_prev_screen_with_mouse), desc="Focus previous screen"),
    Key([mod], "l", lazy.function(focus_next_screen_with_mouse), desc="Focus next screen"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between screens
    Key([mod, "shift"], "h", lazy.function(window_to_prev_screen), desc="Move window to previous screen"),
    Key([mod, "shift"], "l", lazy.function(window_to_next_screen), desc="Move window to next screen"),
    # Move windows between screens and follow focus with mouse
    Key([mod, "shift"], "1", lazy.function(window_to_screen_with_mouse, 0), desc="Move window to screen 1 (left)"),
    Key([mod, "shift"], "2", lazy.function(window_to_screen_with_mouse, 1), desc="Move window to screen 2 (middle)"),
    Key([mod, "shift"], "3", lazy.function(window_to_screen_with_mouse, 2), desc="Move window to screen 3 (right)"),
    # Alternative bindings using hjl for left/middle/right
    Key([mod, "control", "shift"], "h", lazy.window.togroup("screen1", switch_group=True), desc="Move window to left screen"),
    Key([mod, "control", "shift"], "j", lazy.window.togroup("screen2", switch_group=True), desc="Move window to middle screen"),
    Key([mod, "control", "shift"], "l", lazy.window.togroup("screen3", switch_group=True), desc="Move window to right screen"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.function(focus_or_open_app, terminal), desc="Focus or launch terminal"),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    # Application launch keybindings
    Key([mod], "t", lazy.function(focus_or_open_app, "/home/robert/.local/bin/vterm-launcher", "vterm"), desc="Focus or launch vterm"),
    Key([mod], "BackSpace", lazy.function(focus_or_open_app, "firefox"), desc="Focus or launch Firefox"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),

    # Volume control (using pamixer without OSD)
    Key([], "XF86AudioRaiseVolume", lazy.spawn("pamixer -i 5"), desc="Raise volume"),
    Key([], "XF86AudioLowerVolume", lazy.spawn("pamixer -d 5"), desc="Lower volume"),
    Key([], "XF86AudioMute", lazy.spawn("pamixer -t"), desc="Mute volume"),
    Key([mod], "plus", lazy.spawn("pamixer -i 5"), desc="Raise volume"),
    Key([mod], "minus", lazy.spawn("pamixer -d 5"), desc="Lower volume"),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    Key([mod, "shift"], "f", lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawn("rofi -show drun"), desc="Launch rofi application launcher"),
    # Screen lock
    Key([mod, "control"], "Delete", lazy.function(lock_screen), desc="Lock screen"),
    # Scratchpads
    Key([mod], "bracketright", lazy.group["scratchpad"].dropdown_toggle("yazi"), desc="Toggle yazi file manager"),
    Key([mod], "c", lazy.group["scratchpad"].dropdown_toggle("calc"), desc="Toggle calculator"),
    Key([], "F8", lazy.group["scratchpad"].dropdown_toggle("peaclock"), desc="Toggle peaclock"),
]

# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )


# Create 3 fixed groups - one per screen (no app-specific routing)
groups = [
    Group("screen1"),  # Left screen
    Group("screen2"),  # Middle screen
    Group("screen3"),  # Right screen
]

# Add scratchpad group
groups.append(ScratchPad("scratchpad", [
    DropDown("yazi", "wezterm -e yazi", width=0.9, height=0.9, x=0.05, y=0.05, opacity=1.0),
    DropDown("calc", "gnome-calculator", width=0.2, height=0.4, x=0.3, y=0.2, opacity=1.0),
    DropDown("peaclock", "wezterm -e peaclock", width=0.3, height=0.3, x=0.35, y=0.35, opacity=1.0),
]))

# Add group switching keybindings - focus only, no window movement
for i, group_name in enumerate(["screen1", "screen2", "screen3"], 1):
    keys.extend([
        # Switch focus to group/screen with mouse
        Key([mod], str(i), lazy.function(focus_screen_with_mouse, i-1), desc=f"Focus {group_name}"),
    ])

# Create gorgeous gradient border decorations (inspired by hyprland's styling)
focus_gradient = GradientBorder(
    colours=["33ccff", "00ff99"],  # Cyan to green gradient like hyprland
    points=[(0, 0), (1, 1)],       # Diagonal gradient at 45 degrees
    radial=False,
    width=2
)

normal_gradient = GradientBorder(
    colours=["2d2d2d", "5e5c64"],  # Dark gray gradient for inactive
    points=[(0, 0), (1, 1)],
    radial=False,
    width=2
)

layouts = [
    layout.Max(
        border_width=3,
        border_focus=focus_gradient,    # Beautiful gradient border!
        border_normal=normal_gradient,  # Subtle inactive border
        margin=0,
    ),  # Default layout - one window fullscreen (monocle)
    layout.Columns(
        border_focus=focus_gradient,
        border_normal=normal_gradient,
        border_focus_stack=[focus_gradient, GradientBorder(colours=["2a7bde", "1a5fb4"], points=[(0,0),(1,1)], width=3)],
        border_width=3,
        margin=4,
    ),
    layout.MonadTall(
        border_width=3,
        border_focus=focus_gradient,
        border_normal=normal_gradient,
        margin=5,
    ),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

widget_defaults = dict(
    font="sans",
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()

logo = os.path.join(os.path.dirname(libqtile.resources.__file__), "logo.png")

# Configure screens - 3 screens
screens = [
    Screen(
        background="#000000",
        wallpaper=logo,
        wallpaper_mode="center",
    ),
    Screen(
        background="#000000",
    ),
    Screen(
        background="#000000",
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    border_width=4,
    border_focus=focus_gradient,
    border_normal=normal_gradient,
    margin=6,
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
focus_previous_on_window_remove = False
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None


# xcursor theme (string or None) and size (integer) for Wayland backend
wl_xcursor_theme = None
wl_xcursor_size = 24

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"

# Autostart hook
import subprocess
from libqtile import hook

@hook.subscribe.startup_once
def autostart():
    # Run the autostart script if it exists
    home = os.path.expanduser('~/.config/qtile/autostart.sh')
    if os.path.exists(home):
        subprocess.Popen([home])

    # Start auto-lock timer
    reset_auto_lock_timer()

@hook.subscribe.client_new
@hook.subscribe.client_focus
@hook.subscribe.client_urgent_hint_changed
@hook.subscribe.client_killed
@hook.subscribe.layout_change
@hook.subscribe.changegroup
@hook.subscribe.focus_change
def on_activity(*args, **kwargs):
    """Reset auto-lock timer on any user activity"""
    on_user_activity()
