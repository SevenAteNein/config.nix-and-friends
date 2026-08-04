{
  description = "NixOS configuration for computah";

  ###### Inputs #########################################################################
  inputs = {
    # The OS base: stable, tested, updated with security fixes.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # Cherry-pick individual apps from the unstable repo as needed via the overlay
    # in configuration.nix as pkgs.unstable.<name>.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    affinity.url = "github:mrshmllow/affinity-nix";
    nixcord.url = "github:4evy/nixcord";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      # "follows" tells the system to "use THE USER'S nixpkgs instead of downloading
      # its own copy".This prevents having two slightly different nixpkgs evaluated side
      # by side -- more disk, more build time, subtle version mismatches.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      # Noctalia moves fast and its Quickshell dependency wants to be fresh,
      # so we point it at the unstable input rather than stable.
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  ###### Outputs ##########################################################################
  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    # `nixos-rebuild switch --flake .#computah` selects this attribute.
    nixosConfigurations.computah = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      # Makes `inputs` visible inside every module (configuration.nix, home.nix...),
      # so modules can reference e.g. inputs.noctalia or inputs.nixpkgs-unstable.
      specialArgs = { inherit inputs; };

      modules = [
        # THE machine-specific file. The copy in this repo is a placeholder that
        # errors on purpose -- replace it with the one nixos-generate-config
        # creates during installation (see README, step 4).
        ./hardware-configuration.nix

        ./configuration.nix

        # Home Manager as a NixOS module: user environment and system are built
        # and activated together by ONE command (the rebuild). No separate
        # `home-manager switch`, no second tool to keep in sync.
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;     # HM uses the system's pkgs (incl. our overlay + allowUnfree)
          home-manager.useUserPackages = true;   # user packages install to /etc/profiles, standard practice
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.aggi = import ./home.nix;

          # If HM ever finds a pre-existing file where it wants to place a managed
          # one, it renames yours to <file>.hm-backup instead of refusing to
          # activate. This defuses the classic "Existing file ... would be
          # clobbered" error people hit on first activation.
          home-manager.backupFileExtension = "hm-backup";
        }
      ];
    };
  };
}
