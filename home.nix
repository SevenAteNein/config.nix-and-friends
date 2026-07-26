{ pkgs, inputs, ... }:

# aggi's user environment. Everything here is applied by the same
# `rebuild` as the system -- there is no separate home-manager command to run.
#
# Ownership note (the thing you asked about): Home Manager only ever touches
# files that are DECLARED in this file. Every declared file becomes a symlink
# in your home (owned by aggi) pointing at read-only content in /nix/store.
# That read-only-ness is the reproducibility guarantee -- and also why apps
# cannot edit their own config once you declare it. Apps whose GUIs write
# their own settings (VS Code, Noctalia's settings panel) are therefore
# deliberately left UNdeclared here. Anything not named in this file is 100%
# ordinary, mutable, yours.

{
  imports = [ inputs.noctalia.homeModules.default ];

  home.username = "aggi";
  home.homeDirectory = "/home/aggi";

  ###### Noctalia (bar, dock, launcher, notifications, lock screen) ###########

  programs.noctalia = {
    enable = true;
    # `settings` intentionally NOT set. While unset, Noctalia's own graphical
    # settings panel writes ~/.config/noctalia/settings.json freely -- so
    # configure your floating center dock there, live. Once you're happy and
    # want it reproducible, copy that JSON into `settings = { ... };` here.
    # From that moment the file is frozen (read-only) and the GUI can no
    # longer change it -- freeze only when you're done iterating.
  };

  ###### Hyprland (user-level: keybinds, autostart, look) #####################

  wayland.windowManager.hyprland = {
    enable = true;
    # The SYSTEM module (modules/desktop.nix) already provides the Hyprland
    # binary and portal. Setting these to null makes Home Manager manage ONLY
    # the config file -- otherwise you'd have two independently-versioned
    # Hyprland installations shadowing each other.
    package = null;
    portalPackage = null;

    settings = {
      "$mod" = "SUPER";

      monitor = [ ",preferred,auto,1" ];

      exec-once = [ "noctalia-shell" ];   # start the shell with the session

      input = {
        kb_layout = "de";   # the resting default; fcitx5 handles switching
        follow_mouse = 1;
      };

      general = {
        gaps_in = 4;
        gaps_out = 8;
      };

      bind = [
        "$mod, Return, exec, kitty"
        "$mod, Q, killactive,"
        "$mod, F, fullscreen,"
        "$mod, V, togglefloating,"

        # Noctalia's launcher, via its IPC interface.
        # Explore what else is callable with: noctalia-shell ipc list
        "$mod, D, exec, noctalia-shell ipc call launcher toggle"

        # Focus movement
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # Workspaces 1-5 (extend the pattern as needed)
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"

        "$mod SHIFT, E, exit,"   # leave the session
      ];

      bindm = [
        # Mouse: hold SUPER + left/right drag to move/resize windows
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  ###### Waterfox, baked in ###################################################

  # Waterfox is a Firefox fork, so Home Manager's firefox module can drive it:
  # point the module at the Waterfox package.
  programs.firefox = {
    enable = true;
    package = pkgs.waterfox;

    # "Policies" = Mozilla's enterprise mechanism; enforced, not suggested.
    policies = {
      DisableTelemetry = true;
      DisablePocket = true;
      DisableFirefoxStudies = true;
      # Extensions can be force-installed by ID via ExtensionSettings -- add
      # later once you know which you want.
    };

    profiles.aggi = {
      isDefault = true;
      # These become a user.js: about:config values re-applied at every
      # launch. Add your preferences over time.
      settings = {
        "browser.aboutConfig.showWarning" = false;
        "signon.rememberSignons" = false;   # example: no built-in password manager
      };
    };
    # Honest caveat: forks occasionally relocate their profile directory. If
    # Waterfox doesn't pick up the generated profile, the escape hatch is
    # placing the same files under ~/.waterfox/ via home.file. Settings,
    # extensions, search engines can be baked in; live state (cookies,
    # history, logins) is inherently mutable and stays out of Nix's hands.
  };

  ###### Git (you'll want this on day one for the config repo itself) #########

  programs.git = {
    enable = true;
    userName = "aggi";
    userEmail = "aggi@example.org";   # <- change me
  };

  ###### Do not touch #########################################################

  # Same idea as the system stateVersion: a data-format birthmark, set once.
  home.stateVersion = "26.05";
}
