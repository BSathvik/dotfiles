{
  description = "Sathvik's Nix system configs.";

  inputs = {
    # Package sets
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixpkgs-23.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Environment/system management
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Flake utilities
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    flake-utils.url = "github:numtide/flake-utils";

    # jrsonnet
    jrsonnet = { url = "github:CertainLach/jrsonnet"; flake = false; };
  };

  outputs = { self, darwin, home-manager, flake-utils, ... }@inputs:
    let
      inherit (self.lib) attrValues makeOverridable mkForce optionalAttrs singleton;

      homeStateVersion = "23.11";

      nixpkgsDefaults = {
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [ "python3.9-requests-2.29.0" ];
        };
        overlays = attrValues (import ./overlays.nix {
          inherit (inputs) nixpkgs-unstable nixpkgs-stable jrsonnet;
          inherit (self) nixpkgsDefaults;
        });
      };

      personalUser = rec {
        username = "bsat";
        fullName = "Sathvik Birudavolu";
        email = "sathvikb30@gmail.com";
        nixConfigDirectory = "/Users/${username}/.config/nixpkgs";
        hostName = username;
        computerName = "Sathvik’s Personal MBP";
      };

      workUser = personalUser // rec {
        username = "sathvikbirudavolu";
        nixConfigDirectory = "/Users/${username}/.config/nixpkgs";
        # NOTE: Never mess with hostName on a company managed machine!
        hostName = null;
        computerName = "Sathvik’s Work MBP";
        email = "sathvik.birudavolu@kensho.com";
      };
    in
    {
      # Add some additional functions to `lib`.
      lib = inputs.nixpkgs-unstable.lib.extend (_: _: {
        mkDarwinSystem = import ./lib/mkDarwinSystem.nix inputs;
        lsnix = import ./lib/lsnix.nix;
      });

      # Modules -------------------------------------------------------------------------------- {{{

      darwinModules = {
        # My configurations
        bootstrap = import ./darwin/bootstrap.nix;
        defaults = import ./darwin/defaults.nix;
        general = import ./darwin/general.nix;

        # Modules I've created
        users-primaryUser = import ./modules/darwin/users.nix;
      };

      homeManagerModules = {
        # My configurations
        fish = import ./home/fish.nix;
        git = import ./home/git.nix;
        alacritty = import ./home/alacritty.nix;
        neovim = import ./home/neovim.nix;
        packages = import ./home/packages.nix;
        pip = import ./home/pip.nix;

        # Modules I've created
        home-user-info = { lib, ... }: {
          options.home.user-info =
            (self.darwinModules.users-primaryUser { inherit lib; }).options.users.primaryUser;
        };
      };
      # }}}

      # System configurations ------------------------------------------------------------------ {{{

      darwinConfigurations = rec {
        personalMac = makeOverridable self.lib.mkDarwinSystem (personalUser // {
          modules = attrValues self.darwinModules ++ singleton {
            nixpkgs = nixpkgsDefaults;
            nix.registry.my.flake = inputs.self;
          };
          inherit homeStateVersion;
          homeModules = attrValues self.homeManagerModules;
          system = "x86_64-darwin";
        });

        workMac = self.darwinConfigurations.personalMac.override
          (old: old // workUser // {
            extraHomeModules = attrValues {
              work = import ./home/work.nix;
            };
          });

        # Config with small modifications needed/desired for CI with GitHub workflow
        githubCI = self.darwinConfigurations.personalMac.override {
          system = "x86_64-darwin";
          username = "runner";
          nixConfigDirectory = "/Users/runner/work/nixpkgs/nixpkgs";
          extraModules = singleton {
            environment.etc.shells.enable = mkForce false;
            environment.etc."nix/nix.conf".enable = mkForce false;
          };
        };
      };

      # Config I use with non-NixOS Linux systems (e.g., cloud VMs etc.)
      # Build and activate on new system with:
      # `nix build .#homeConfigurations.bsat.activationPackage && ./result/activate`
      # TODO: Should test building for non-NixOS Linux this out at some point
      homeConfigurations.bsat = makeOverridable home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs-unstable (nixpkgsDefaults // { system = "x86_64-linux"; });
        modules = attrValues self.homeManagerModules ++ singleton ({ config, ... }: {
          home.username = config.home.user-info.username;
          home.homeDirectory = "/home/${config.home.username}";
          home.stateVersion = homeStateVersion;
          home.user-info = personalUser // {
            nixConfigDirectory = "${config.home.homeDirectory}/.config/nixpkgs";
          };
        });
      };

      # Config with small modifications needed/desired for CI with GitHub workflow
      homeConfigurations.runner = self.homeConfigurations.bsat.override (old: {
        modules = old.modules ++ singleton {
          home.username = mkForce "runner";
          home.homeDirectory = mkForce "/home/runner";
          home.user-info.nixConfigDirectory = mkForce "/home/runner/work/nixpkgs/nixpkgs";
        };
      });
      # }}}

    } // flake-utils.lib.eachDefaultSystem (system: {
      # Re-export `nixpkgs-unstable` with overlays.
      # This is handy in combination with setting `nix.registry.my.flake = inputs.self`.
      # Allows doing things like `nix run my#prefmanager -- watch --all`
      legacyPackages = import inputs.nixpkgs-unstable (nixpkgsDefaults // { inherit system; });

      formatter = self.legacyPackages.${system}.nixpkgs-fmt;

      # Development shells ----------------------------------------------------------------------{{{
      # Shell environments for development
      # With `nix.registry.my.flake = inputs.self`, development shells can be created by running,
      # e.g., `nix develop my#python`.
      devShells = let pkgs = self.legacyPackages.${system}; in
        {
          python = pkgs.mkShell {
            name = "python310";
          };
          pypi = pkgs.mkShell {
            name = "pypi";
            inputsFrom = attrValues
              {
                inherit (pkgs) pyright pkg-config;
              } ++ singleton (
              pkgs.python39.withPackages (ps: with ps; [ (pkgs.callPackage { }) ])
            );
          };
        };
      # }}}
    });
}
# vim: foldmethod=marker
