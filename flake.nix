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
        overlays = attrValues self.overlays;
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
      };
    in
    {
      # Add some additional functions to `lib`.
      lib = inputs.nixpkgs-unstable.lib.extend (_: _: {
        mkDarwinSystem = import ./lib/mkDarwinSystem.nix inputs;
        lsnix = import ./lib/lsnix.nix;
      });

      # Overlays --------------------------------------------------------------------------------{{{

      overlays = {
        # Overlays to add different versions `nixpkgs` into package set
        pkgs-master = _: prev: {
          pkgs-master = import inputs.nixpkgs-master {
            inherit (prev.stdenv) system;
            inherit (nixpkgsDefaults) config;
          };
        };
        pkgs-stable = _: prev: {
          pkgs-stable = import inputs.nixpkgs-stable {
            inherit (prev.stdenv) system;
            inherit (nixpkgsDefaults) config;
          };
        };
        pkgs-unstable = _: prev: {
          pkgs-unstable = import inputs.nixpkgs-unstable {
            inherit (prev.stdenv) system;
            inherit (nixpkgsDefaults) config;
          };
        };

        # these checks keep failing, let's override this for now
        fzf-fish = final: prev: {
          fishPlugins = prev.fishPlugins.overrideScope' (ffinal: fprev: {
            fishtape_3 = fprev.fishtape_3.overrideAttrs (oldAttrs: {
              checkPhase = null;
            });
            fzf-fish = fprev.fzf-fish.overrideAttrs (oldAttrs: {
              checkPhase = null;
            });
          });
        };

        # jrsonnet postInstall creates a $out/bin/jsonnet link and .dylib for c++ binding 
        # that's in conflict with jsonnet, don't need either
        # I want both since jrsonnet doesn't ship with jsonnetfmt
        jrsonnet = final: prev: {
          jrsonnet = prev.jrsonnet.overrideAttrs {
            postInstall = ''
              rm -rf $out/lib/
            '';
          };
        };
      };
      # }}}

      # Modules -------------------------------------------------------------------------------- {{{

      darwinModules = {
        # My configurations
        bootstrap = import ./darwin/bootstrap.nix;
        defaults = import ./darwin/defaults.nix;
        general = import ./darwin/general.nix;
        homebrew = import ./darwin/homebrew.nix;

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

      darwinConfigurations = {
        # Minimal macOS configurations to bootstrap systems
        bootstrap-x86 = makeOverridable darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          modules = [ ./darwin/bootstrap.nix { nixpkgs = nixpkgsDefaults; } ];
        };

        personalMac = makeOverridable self.lib.mkDarwinSystem (personalUser // {
          modules = attrValues self.darwinModules ++ singleton {
            nixpkgs = nixpkgsDefaults;
            nix.registry.my.flake = inputs.self;
          };
          # TODO: Re-enable when https://github.com/NixOS/nixpkgs/issues/243685 is resolved.
          # extraModules = singleton { nix.linux-builder.enable = true; };
          extraModules = singleton {
            homebrew.enable = mkForce false;
          };
          inherit homeStateVersion;
          homeModules = attrValues self.homeManagerModules;
          system = "x86_64-darwin";
        });

        workMac = self.darwinConfigurations.personalMac.override (old: old // workUser);

        # Config with small modifications needed/desired for CI with GitHub workflow
        githubCI = self.darwinConfigurations.personalMac.override {
          system = "x86_64-darwin";
          username = "runner";
          nixConfigDirectory = "/Users/runner/work/nixpkgs/nixpkgs";
          extraModules = singleton {
            environment.etc.shells.enable = mkForce false;
            environment.etc."nix/nix.conf".enable = mkForce false;
            homebrew.enable = mkForce false;
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
              pkgs.python39.withPackages (ps: with ps; [ (pkgs.callPackage kensho-deploy { }) ])
            );
          };
        };
      # }}}
    });
}
# vim: foldmethod=marker
