{ pkgs, ... }:

# System language: German. Input systems: German, Hebrew, Arabic (phonetic-ish
# QWERTY), Dvorak, and Chinese Pinyin.
#
# The key distinction: the first four are keyboard LAYOUTS (static keymaps).
# Pinyin is an input METHOD -- you type Latin letters and an engine composes
# candidate characters. No static keymap can do that, so we run fcitx5.
#
# Recommended setup (done graphically after first boot, see README step 6):
# let fcitx5 manage ALL FIVE as its input-method list, switched with one
# hotkey (default Ctrl+Space). Why not XKB groups in Hyprland instead? XKB
# has a hard limit of 4 simultaneous layout groups (an ancient X11 protocol
# constraint that Wayland inherited via libxkbcommon) -- your four non-Chinese
# layouts would exactly max it out, stranding Pinyin on a separate switching
# mechanism. One switcher for everything is better.

{
  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "de_DE.UTF-8";
  i18n.extraLocales = ["en_US.UTF-8/UTF-8"];

	i18n.extraLocaleSettings = {
		LC_TELEPHONE = "es_VE.UTF-8";
	};

  # The pre-GUI text console (Ctrl+Alt+F1 etc.) gets a German keymap too.
  console.keyMap = "de";

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      # Speak Wayland's native input protocol instead of X11 compatibility shims.
      waylandFrontend = true;
      addons = with pkgs; [
        qt6Packages.fcitx5-chinese-addons   # provides the Pinyin engine
        fcitx5-gtk              # bridge so GTK apps (Inkscape, ...) receive composed text
        qt6Packages.fcitx5-qt   # same bridge for Qt apps (MuseScore, VLC, ...)
        qt6Packages.fcitx5-configtool       # the graphical settings app you'll use in README step 6
      ];
    };
  };

  # On "Arabic QWERTY phonetic": XKB's Arabic layout ships several variants --
  # `qwerty`, `buckwalter` (a strict phonetic transliteration), `mac-phonetic`.
  # Which one matches the layout in your head varies by person. On the running
  # system, list them with:   localectl list-x11-keymap-variants ara
  # and pick the variant when adding the layout in fcitx5's config tool.
  # Swapping later is trivial.
}
