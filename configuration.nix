{ inputs, pkgs, ... }:

{
  imports = [
    ./modules/hardware.nix
    ./modules/locale-input.nix
    ./modules/desktop.nix
    ./modules/software.nix
    ./modules/services.nix
  ];

  ###### Boot ##################################################################

  # systemd-boot: the simple, modern UEFI bootloader. Every rebuild adds a new
  # entry to its menu, which is how NixOS rollbacks work: old generations stay
  # bootable until garbage-collected.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 15; # keep the boot menu tidy
  boot.loader.efi.canTouchEfiVariables = true;

  ###### Identity & networking ################################################

  networking.hostName = "computah";.
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  ###### The user #############################################################

  users.users.aggi = {
    isNormalUser = true;
    description = "aggi";
    extraGroups = [
      "wheel"           # may use sudo
      "networkmanager"  # may manage network connections without sudo
      "vboxusers"       # may pass USB devices etc. to VirtualBox guests
      "video"
    ];
    # First-login password ONLY. It applies when the user is first created;
    # log in, run `passwd`, and it is superseded permanently.
    initialPassword = "changeme";
  };

  ###### Nix / nixpkgs behavior ###############################################

  # Spotify, Discord, VS Code, Steam etc. carry unfree licenses; Nix makes you
  # opt in explicitly rather than silently shipping proprietary software.
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "googleearth-pro-7.3.7.1155"
  ];

  # The overlay that creates pkgs.unstable.<name>: a window into the
  # nixpkgs-unstable input, for the handful of apps where we want the newest
  # release instead of the stable snapshot.
  nixpkgs.overlays = [
    inputs.affinity.overlays.default
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = prev.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    })
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;  # hard-links identical files in the store; saves gigabytes
  };

  # Old system generations accumulate (that's what makes rollbacks possible).
  # This prunes generations older than 30 days, weekly, so the 4 TB drive
  # doesn't slowly fill with history you'll never boot again.
  nix.gc = {
    automatic = false;
  };

  # Nix helper (nh) - makes nix commands/aliases and package management more
  # accessible, and allows one to "nom" on "dix"
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep 7 --keep-since 4d";
    flake = "/home/aggi/nixos-config";
  };

  ###### Conveniences #########################################################

  environment.shellAliases = {
    # The alias lives in the config, so it's versioned and
    # identical on every machine that uses this flake.
    rebuild = "sudo nixos-rebuild switch --flake /home/aggi/nixos-config#computah";
    update  = "cd /home/aggi/nixos-config && nix flake update && sudo nixos-rebuild switch --flake .#computah";
  };
  
  programs.kdeconnect.enable = true;

  ###### NIIIIICHT BERÜHREN #########################################################

  # NOT "the version you are running". This records which release's data
  # formats (databases, state directories) this installation was born with, so
  # future upgrades know what to migrate. Set once at install, never bumped
  # casually.
  system.stateVersion = "26.05";
}
