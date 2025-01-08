{
  description = "Sathvik's Nix system configs.";

  inputs = {
    # Package sets
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Environment/system management
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Flake utilities
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    flake-utils.url = "github:numtide/flake-utils";

    # Use my fork because the maintainer keeps removing darwin support for no reason
    jrsonnet.url = "github:BSathvik/jrsonnet";

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland/?ref=refs/tags/v0.43.0&submodules=1";
      inputs.nixpkgs.follows = "nixos-unstable";
    };

    # community wayland nixpkgs
    # nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    # anyrun - a wayland launcher
    anyrun = {
      # https://github.com/anyrun-org/anyrun/pull/154
      url = "github:anyrun-org/anyrun/9e14b5946e413b87efc697946b3983d5244a1714";
      inputs.nixpkgs.follows = "nixos-unstable";
    };

    nur-ryan4yin = {
      url = "github:ryan4yin/nur-packages";
      inputs.nixpkgs.follows = "nixos-unstable";
    };

    aerospace = {
      url = "tarball+https://github.com/nikitabobko/AeroSpace/releases/download/v0.16.2-Beta/AeroSpace-v0.16.2-Beta.zip";
      flake = false;
    };

    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    nixpkgs-python.url = "github:cachix/nixpkgs-python";
  };

  outputs = { self, darwin, home-manager, flake-utils, ... }@inputs:
    let
      inherit (self.lib) attrValues makeOverridable mkForce singleton;

      homeStateVersion = "23.11";

      nixpkgsDefaults = {
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [ "python3.9-requests-2.29.0" ];
        };
        overlays = attrValues
          (import ./myOverlays.nix {
            inherit (inputs) nixpkgs-unstable nixpkgs-stable jrsonnet aerospace ghostty;
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

      florina = personalUser // rec {
        username = "florina";
        hostName = "florina";
        nixConfigDirectory = "/home/${username}/.config/nixpkgs";
        computerName = "Florina";
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
      });

      # Modules -------------------------------------------------------------------------------- {{{

      darwinModules = {
        # My configurations
        darwin = import ./darwin.nix;

        # Modules I've created
        users-primaryUser = import ./lib/users.nix;
      };

      homeManagerModules = {
        # My configurations
        fish = import ./home/fish.nix;
        tmux = import ./home/tmux.nix;
        alacritty = import ./home/alacritty.nix;
        ghostty = import ./home/ghostty.nix;
        packages = import ./home/packages.nix;

        # Modules I've created
        home-user-info = { lib, ... }: {
          options.home.user-info =
            (self.darwinModules.users-primaryUser { inherit lib; }).options.users.primaryUser;
        };
      };
      # }}}

      # System configurations ------------------------------------------------------------------ {{{

      darwinConfigurations = {
        # Minimal macOS configurations to bootstrap systems
        bootstrap-x86 = makeOverridable darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          modules = [ ./darwin.nix { nixpkgs = nixpkgsDefaults; } ];
        };

        personalMac = makeOverridable self.lib.mkDarwinSystem (personalUser // {
          modules = attrValues self.darwinModules ++ singleton {
            nixpkgs = nixpkgsDefaults;
            nix.registry.my.flake = inputs.self;
          };
          inherit homeStateVersion;
          homeModules = (attrValues self.homeManagerModules) ++ [ (import ./home/darwin.nix) ];
          system = "x86_64-darwin";
        });

        workMac = self.darwinConfigurations.personalMac.override
          (old: old // workUser // {
            extraHomeModules = [
              (import ./home/work.nix)
            ];
          });

        # Config with small modifications needed/desired for CI with GitHub workflow
        githubCI = self.darwinConfigurations.personalMac.override
          {
            system = "x86_64-darwin";
            username = "runner";
            nixConfigDirectory = "/Users/runner/work/nixpkgs/nixpkgs";
            extraModules = singleton {
              environment.etc.shells.enable = mkForce false;
              environment.etc."nix/nix.conf".enable = mkForce false;
            };
          };
      };

      nixosConfigurations = {
        florina = inputs.nixos-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager
            ({ config, ... }: {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # These are extra arguments for flakes that are passed into all the home-manager 
              # modules other than the usual `pkgs/lib/config` 
              home-manager.extraSpecialArgs = { inherit (inputs) anyrun hyprland nur-ryan4yin; };
              home-manager.backupFileExtension = "backup1";

              home-manager.users.florina = { pkgs, ... }: {
                imports = attrValues self.homeManagerModules ++ [
                  inputs.anyrun.homeManagerModules.default
                  (import ./home/hyprland/default.nix)
                  (import ./home/hyprland/anyrun.nix)
                  (import ./home/desktop.nix)
                  (import ./home/xdg.nix)
                ];

                # unzip required for nvim
                home.packages = [ pkgs.unzip pkgs.gcc14 pkgs.gnumake ];

                home.username = "florina";
                home.homeDirectory = "/home/florina";
                home.user-info = florina;

                # The state version is required and should stay at the version you
                # originally installed.
                home.stateVersion = "24.05";
              };
            })
          ];
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
      devShells =
        let
          pkgs = self.legacyPackages.${system};
          old-python = inputs.nixpkgs-python.packages.${system};
        in
        {
          python38 = pkgs.mkShell {
            name = "python38";
            buildInputs =
              [ old-python."3.8.0" ] ++
              # For coherence rust project for data-pipeline/workers/nerd
              [ pkgs.rustc pkgs.libiconv ];
            shellHook = ''
              poetry env use ${old-python."3.8.0"}/bin/python
            '';
          };
          python310 = pkgs.mkShell {
            name = "python310";
            buildInputs = with pkgs; [ python310 postgresql openssl ];
            shellHook = ''
              poetry env use ${pkgs.python310}/bin/python
            '';
          };
          python39 = pkgs.mkShell {
            name = "python39";
            buildInputs = with pkgs; [ python39 postgresql openssl ];
            shellHook = ''
              poetry env use ${pkgs.python39}/bin/python
            '';
          };
          nerd-web-service = pkgs.mkShell {
            name = "nerd-web-service";
            buildInputs =
              [ old-python."3.8.0" ] ++
              [ pkgs.rustc pkgs.llvmPackages_12.openmp ];
            shellHook = ''
              poetry env use ${old-python."3.8.0"}/bin/python
            '';
            # shellHook = ''
            #   poetry env use ${old-python."3.9.0"}/bin/python
            # '';
          };
        };
    });
}
# vim: foldmethod=marker
