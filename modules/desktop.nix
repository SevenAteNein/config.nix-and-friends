{ pkgs, ... }:

# The desktop stack, bottom to top:
#   Hyprland  = the Wayland compositor (window management, rendering)
#   Noctalia  = the shell ON TOP of it (bar, dock, launcher, notifications...)
#               -- configured on the user side, see home.nix
#   SDDM      = the login screen in front of it all

{
  programs.hyprland = {
    enable = true;
    # Also wires up xdg-desktop-portal-hyprland: the piece that makes
    # screen-sharing work in OBS and Discord under Wayland.

    # Compatibility layer that lets X11-only apps (Discord, VirtualBox GUI...)
    # run inside a Wayland session.
    xwayland.enable = true;
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.displayManager.defaultSession = "hyprland";
  services.xserver.xkb.layout = "de";

  ###### Audio ################################################################

  # rtkit lets audio threads request realtime scheduling -> no crackle under load.
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;  # audio for 32-bit games; same logic as the 32-bit GPU flag
    # PipeWire impersonating PulseAudio: Discord, Spotify, browsers all still
    # speak the Pulse protocol.
    pulse.enable = true;
  };

  ###### Portals ##############################################################

  # Hyprland's own portal only handles screencast/screenshot. The GTK portal
  # supplies everything else portals are asked for -- most importantly the
  # file-open/save dialogs many apps request through the portal system.
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  ###### Electron apps on Wayland #############################################

  # Tells Electron/Chromium apps (Discord, VS Code, Signal, ...) to render as
  # native Wayland windows instead of through XWayland. Why you care: crisp
  # (non-blurry) rendering and working IME input from fcitx5.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  ###### Cursors (system-wide presense declarations)  #########################

  

  ###### Fonts ################################################################
  
  # The best for last in this module: fonts! And oh what bounty!
  # Text in non-Latin-script languages only renders if fonts therefor exist. 
  # Noto ("no tofu" -- tofu = the □□□ boxes) covers effectively every script.
  # Your personal standardized fonts slot in right here later; adding
  # fonts.fontconfig.defaultFonts settings then makes them the system default.
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans          # Chinese/Japanese/Korean coverage
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono    # monospace with the icon glyphs shell bars like to use
  ];
}
