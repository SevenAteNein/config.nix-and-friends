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
    btop	 # terminal system monitor: processes, kill, temps. etc
    yazi	 # terminal file manager
    nix-diff	 # "why did this rebuild? -- illustrates diff between two derivs

    ###### utilities ##########################################################
    impression             # bootable disk utility
    networkmanagerapplet   # GUI for NetworkManager connections (the VPN toggle
			   # window 
    gparted		   # partition manager -- for USB sticks and foreign disks
    mission-center	   # GUI system monitor
    kdePackages.dolphin	   # Qt/Noctalia-respecting graphical file manager
    kdePackages.qrca	   # QR code maker and parser
    fastfetch
    chafa                  # Terminal image-to-ASCII utility

    ###### browsers & communication ###########################################
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
    element-desktop	   # Matrix client, encrypted FOSS Discord substitute
    newsflash		   # RSS reader

    ###### creative / media ###################################################
    unstable.blender       # newest Blender, from the unstable input
    # unstable.blender-hip # variant with AMD-GPU (HIP) Cycles rendering; not
                           # prebuilt by the cache -> long local compile, and
                           # RDNA4 compute support is bleeding-edge (README).
    unstable.musescore
    muse-sounds-manager
    inkscape
    audacity
    obs-studio             # Wayland screen capture works via the Hyprland portal
    vlc
    krita
    gimp
### bambu-studio
    davinci-resolve
    ascii-draw		   # GUI image-to-ASCII utility
    newmacs		   # Image viewer
    calligraphy 	   # ASCII-art banner generation utility

    ###### office & research ##################################################
    libreoffice-qt6-fresh  # the whole suite: Writer, Calc, Impress.
                           # qt6 build = matches your Qt-based desktop visually.
    hunspell               # spellcheck engine LibreOffice looks for
    hunspellDicts.de_DE
    zotero
    obsidian		   # a de facto digital Zettelkasten, which you will eventually
			   # make a better version of...
    texstudio
    texliveMedium
    
    ###### GIS ################################################################
    qgis
    googleearth-pro

    ###### music & misc #######################################################
    spotify
    qbittorrent
    hieroglyphic           # draw a symbol, get its LaTeX command

    ###### windows-software translation #######################################
    wineWow64Packages.staging  # "WoW" = 64-bit and 32-bit Wine together;
                             # staging = newer patch set
    winetricks
    bottles                # GUI Wine-prefix manager; fills the Crossover role
                           # (Crossover itself is proprietary and not packaged
                           # for NixOS -- see README)
    ###### games ##############################################################
    heroic                 # Epic/GOG/Amazon launcher
    prismlauncher          # open source Minecraft lanucher
  ];

  # Steam gets a module rather than a plain package because it needs special
  # treatment: an FHS sandbox (Steam expects the "normal" Linux filesystem
  # layout that NixOS doesn't have), 32-bit graphics, and optional firewall
  # openings for Remote Play.
  programs.steam.enable = true;

  # Ollama's terminal client etc. live in services.nix with their services.
}
