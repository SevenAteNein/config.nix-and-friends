{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ###### terminals & dev ####################################################
    kitty        # a terminal emulator -- Hyprland ships none, and you need one!
    neovim
    vscode       # DELIBERATELY installed as a plain package rather than through
                 # Home Manager's vscode module: this keeps settings.json and
                 # extensions writable by VS Code's own GUI. (See "who owns my
                 # files" in the README.)
    opencode

    ###### browsers & communication ###########################################
    waterfox               # its declarative config lives in home.nix
    tor-browser            # stable channel, deliberately unmodified: Tor's
                           # anonymity depends on every user's browser looking
                           # identical -- do not customize it, and nixpkgs does
                           # not package the fast-moving Alpha channel.
    signal-desktop
    (discord.override { withOpenASAR = true; })  # OpenASAR patched in at the
                                                 # package level = fully declarative
    betterdiscordctl       # BetterDiscord injects into Discord's MUTABLE config
                           # dir, so it stays imperative: run
                           #   betterdiscordctl install
                           # once, and again after Discord updates stomp it.
    protonmail-desktop

    ###### creative / media ###################################################
    unstable.blender       # newest Blender, from the unstable input
    # unstable.blender-hip # variant with AMD-GPU (HIP) Cycles rendering; not
                           # prebuilt by the cache -> long local compile, and
                           # RDNA4 compute support is bleeding-edge (README).
    unstable.musescore     # unstable = your best shot at the 4.7.x line;
                           # check what you actually got: mscore --version
    inkscape
    audacity
    obs-studio             # Wayland screen capture works via the Hyprland portal
    vlc

    ###### office & research ##################################################
    libreoffice-qt6-fresh  # the whole suite: Writer, Calc, Impress.
                           # qt6 build = matches your Qt-based desktop visually.
    hunspell               # spellcheck engine LibreOffice looks for
    hunspellDicts.de_DE
    zotero

    ###### music & misc #######################################################
    spotify
    qbittorrent
    hieroglyphic           # draw a symbol, get its LaTeX command

    ###### the windows-software layer #########################################
    wineWowPackages.staging  # "WoW" = 64-bit and 32-bit Wine together;
                             # staging = newer patch set
    winetricks
    bottles                # GUI Wine-prefix manager; fills the Crossover role
                           # (Crossover itself is proprietary and not packaged
                           # for NixOS -- see README)
    heroic                 # Epic/GOG/Amazon launcher
  ];

  # Steam gets a module rather than a plain package because it needs special
  # treatment: an FHS sandbox (Steam expects the "normal" Linux filesystem
  # layout that NixOS doesn't have), 32-bit graphics, and optional firewall
  # openings for Remote Play.
  programs.steam.enable = true;

  # Ollama's terminal client etc. live in services.nix with their services.
}
