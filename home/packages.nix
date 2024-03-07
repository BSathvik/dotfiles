{ config, lib, pkgs, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  inherit (config.home.user-info) nixConfigDirectory;
in
{
  # Put neovim configuration located in this repository into place in a way that edits to the
  # configuration don't require rebuilding the `home-manager` environment to take effect.
  xdg.configFile."nvim/lua".source = mkOutOfStoreSymlink "${nixConfigDirectory}/nvim";
  programs.neovim = {
    enable = true;
    extraConfig = "lua require('init')";
  };

  programs.git = {
    enable = true;
    # Enhanced diffs
    delta.enable = true;
    ignores = [ ".DS_Store" ];

    userEmail = config.home.user-info.email;
    userName = config.home.user-info.fullName;

    extraConfig = {
      diff.colorMoved = "default";
      pull.rebase = true;
      core.editor = "nvim";
    };

    aliases = {
      a = "add";
      d = "diff";
      ds = "diff --staged";
      pl = "pull";
      pu = "push";
      s = "status";
      co = "checkout";
      cob = "checkout -b";
      com = "checkout master";
      cm = "commit -m";
      rs = "restore --staged";
    };
  };

  # GitHub CLI
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      editor = "nvim";
    };
  };

  programs.fzf = {
    enableFishIntegration = true;
  };

  # Bat, a substitute for cat.
  # https://github.com/sharkdp/bat
  programs.bat = {
    enable = true;
    config = {
      style = "plain";
    };
  };

  # Direnv, load and unload environment variables depending on the current directory.
  # https://direnv.net
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.ssh = {
    enable = true;
    controlPath = "~/.ssh/%C"; # ensures the path is unique but also fixed length
    matchBlocks = {
      "github.com" = {
        identityFile = "~/.ssh/github";
        extraOptions = {
          UseKeychain = "yes";
          AddKeysToAgent = "yes";
        };
      };
    };
  };

  # Zoxide, a faster way to navigate the filesystem
  # https://github.com/ajeetdsouza/zoxide
  programs.zoxide.enable = true;

  home.packages = lib.attrValues
    ({
      # Some basics
      inherit (pkgs)
        coreutils
        wget
        du-dust# fancy version of `du`
        eza# fancy version of `ls`
        fzf
        fd# fancy version of `find`
        btop# fancy version of `top`
        hyperfine# benchmarking tool
        parallel# runs commands in parallel
        ripgrep# better version of `grep`
        tealdeer# rust implementation of `tldr`
        diff-so-fancy# used for `git diff`
        fq
        jq
        yq
        tailspin
        tmux-xpanes
        ;

      # Kensho stuff
      inherit (pkgs)
        aws-iam-authenticator
        go-jsonnet#ships with jsonnetfmt (issue with `jsonnet` build)
        jrsonnet# is _blazingling_ fast
        okta-aws-cli
        # postgresql_16# Required for psql
        postgresql# Required for psql
        ;

      # Dev stuff
      inherit (pkgs)
        nodejs
        poetry
        go# Required for jsonnet-language-server
        cargo# Required for rnix-ls
        rustc
        rustfmt
        nixpkgs-fmt
        shellcheck
        ;

      # Useful nix related tools
      inherit (pkgs)
        cachix# adding/managing alternative binary caches hosted by Cachix
        comma# run software from without installing it
        nix-output-monitor# get additional information while building packages
        nix-tree# interactively browse dependency graphs of Nix derivations
        nix-update# swiss-knife for updating nix packages
        nixpkgs-review# review pull-requests on nixpkgs
        statix# lints and suggestions for the Nix programming language
        ;

    } // lib.optionalAttrs pkgs.stdenv.isDarwin {
      inherit (pkgs)
        m-cli# useful macOS CLI commands
        ;
    }) ++ [
    (pkgs.python310.withPackages (ps: with ps; [ pipx black pynvim ]))
    pkgs.unixtools.watch
  ];
}
