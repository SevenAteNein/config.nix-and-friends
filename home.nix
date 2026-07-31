{ pkgs, inputs, ... }:

# Your user environment. Everything here is applied by the same
# `rebuild` as the system -- there is no separate home-manager command to run.
# (p.s., Aggi...keep it clean.)
#
# Ownership note: Home Manager only ever touches
# files that are DECLARED in this file. Every declared file becomes a symlink
# in your home (owned by aggi) pointing at read-only content in /nix/store.
# That read-only-ness is the reproducibility guarantee -- and also why apps
# cannot edit their own config once you declare it. Apps whose GUIs write
# their own settings (VS Code, Noctalia's settings panel) are therefore
# deliberately left UNdeclared here. Anything not named in this file is 100%
# ordinary, mutable, yours.

  ###### Imported homeModules #################################################
{
  imports = [
    inputs.noctalia.homeModules.default
    inputs.nixcord.homeModules.default
 ];

  ###### Home Manager options ################################################

  home.username = "aggi";
  home.homeDirectory = "/home/aggi";
   home.pointerCursor = {
    package = pkgs.apple-cursor;
    name = "macOS";        # verify: ls ${pkgs.apple-cursor}/share/icons
    size = 24;
    gtk.enable = true;
  }; # Make a version that has a spinning snowflake instead of the quadrant circle


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
    configType = "hyprlang"; # emit old-style "hyperland.conf" until HM's Lua translator matures

    settings = {
      "$mod" = "SUPER";

      monitor = [ ",preferred,auto,1" ];
      keyboard.layout = "de";
      cursor = {
	theme = "macOS";
	size = 24;
	path = "${pkgs.apple-cursor}/share/icons";
      };

      exec-once = [ "LIBGL_ALWAYS_SOFTWARE=1 noctalia" ];

      input = {
        kb_layout = "de";   # the resting default; fcitx5 handles switching
        follow_mouse = 1;
      };

      general = {
        gaps_in = 4;
        gaps_out = 8;
      };

      bind = [
        "$mod, Return, exec, LIBGL_ALWAYS_SOFTWARE=1 kitty"
        "$mod, Q, killactive,"
        "$mod, F, fullscreen,"
        "$mod, V, togglefloating,"

        # Noctalia's launcher;
        # Originally you had this as "$mod, D, exec, noctalia-shell ipc call launcher toggle"
        # Explore what else is callable with: noctalia-shell ipc list
        "$mod, D, exec, noctalia msg panel-toggle launcher"

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

  ###### LibreWolf (Waterfox-esque browser)  ###############################

  programs.firefox = {
    enable = true;
    package = pkgs.librewolf;

    # "Policies" = Mozilla's enterprise mechanism; enforced, not suggested.
  policies = {
      DisableTelemetry = true;
      DisablePocket = true;
      DisableFirefoxStudies = true;

      ExtensionSettings = {
        # IDs below are exact (from your about:support).
        # VERIFY each install_url if you encounter a roadblock

        "adguardadblocker@adguard.com" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/adguard-adblocker/latest.xpi";
          installation_mode = "normal_installed";
        };
        "78272b6fa58f4a1abaac99321d503a20@proton.me" = {          # Proton Pass
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/proton-pass/latest.xpi";
          installation_mode = "normal_installed";
        };
        "simple-translate@sienori" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/simple-translate/latest.xpi";
          installation_mode = "normal_installed";
        };
        "{f282d54d-83cc-45f5-b3e5-65888de1682b}" = {              # LibKey Nomad
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/libkey-nomad/latest.xpi";
          installation_mode = "normal_installed";
        };
        "{96ef5869-e3ba-4d21-b86e-21b163096400}" = {              # Font Fingerprint Defender
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/font-fingerprint-defender/latest.xpi";
          installation_mode = "normal_installed";
        };
        "firefox-extension@steamdb.info" = {                      # SteamDB
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/steamdb/latest.xpi";
          installation_mode = "normal_installed";
        };
        "jid0-bnmfwWw2w2w4e4edvcdDbnMhdVg@jetpack" = {            # Tab Reloader
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/tab-reloader/latest.xpi";
          installation_mode = "normal_installed";
        };
        "languagetool-webextension@languagetool.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/languagetool/latest.xpi";
          installation_mode = "normal_installed";
        };
        "{e6e36c9a-8323-446c-b720-a176017e38ff}" = {              # Torrent Control
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/torrent-control/latest.xpi";
          installation_mode = "normal_installed";
        };
        "{8ea65087-7dfb-4140-9943-6ecdf404a402}" = {              # Wiki Journey
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/wiki-journey/latest.xpi";
          installation_mode = "normal_installed";
        };
        "{79875c40-ed9d-481a-a274-929daf40717d}" = {              # View (paywall remover)
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/viewfirefox/latest.xpi";
          installation_mode = "normal_installed";
        };
         ### Themes  ###
        "{b9d44adf-7e1f-4d31-b1bb-e8a4b4d6c321}" = {              # Persona 5 Animated Stars (theme)
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/persona-5-animated-stars/latest.xpi";
          installation_mode = "normal_installed";
        };      # closes theme
      };        # closes ExtensionSettings
    };          # closes policies

    profiles.aggi = {
      isDefault = true;
      settings = {
        "browser.aboutConfig.showWarning" = false;
        "signon.rememberSignons" = false;
        # LibreWolf clears cookies on shutdown by default, which logs Proton Pass
        # out every session -- uncomment if that bites:
        # "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
      };
    };
  };            # closes programs.firefox

  ###### Nixcord (w/Equicord and OpenASAR enabled) ########################

  programs.nixcord = {
    enable = true;
    legcord = {
      enable = true;
      equicord.enable = true;
      settings = {
	channel = "stable";
	tray = "dynamic";
	minimizeToTray = true;
	mods = [ "equicord" ];
	doneSetup = true;
    };
 
    # Theming
### quickCss = "/* css goes here */";
    config = {
      useQuickCss = true;
###   themeLinks = [
###     "https://raw.githubusercontent.com/link/to/some/theme.css"
###   ];
      frameless = true;

      plugins = {
        hideMedia.enable = true;
        ignoreActivities = {
          enable = true;
          ignorePlaying = true;
          ignoredActivities = [
            { id = "game-id"; name = "League of Legends"; type = 0; }
          ];
        };
      };

    # for Equicord plugins outside the  upstream plugin list
### userPlugins = {
###   someCoolPlugin = "github:someUser/someCoolPlugin/abc123def456...";

      # Local path (requires --impure with flakes)
###   myLocalPlugin = "/home/user/projects/myPlugin";

      # Nix path literal
###   anotherPlugin = ./plugins/anotherPlugin;
### };

### extraConfig.plugins = {
###   someCoolPlugin.enable = true;
###   myLocalPlugin.enable = true;
###   anotherPlugin.enable = true;
     };
   }; 
 };
  

  ###### Git ###############################################################

  programs.git = {
    enable = true;
    settings = {
    user = {
    name = "SevenAteNein";
    email = "anton-august@macklin.de";
  };
  credential.helper = "store";
 };
};

  ###### Affinity ##########################################################
 
  home.packages = [
    pkgs.affinity-v3
  ];

  ###### BERÜHRE NICHT! ####################################################

  # Same idea as the system stateVersion: a data-format birthmark, set once.
  home.stateVersion = "26.05";
}
