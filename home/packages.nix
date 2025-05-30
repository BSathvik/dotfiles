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
    extraPackages = with pkgs; [
      # Language Servers
      docker-ls
      rust-analyzer
      pyright
      lua-language-server
      jsonnet-language-server
      gopls
      nixd
      superhtml
      basedpyright

      # Required for neorg
      luajitPackages.luarocks

      # Formatters
      stylua
      rustfmt
      nixpkgs-fmt
      black
      ruff
      # NOTE: Just install `ocamlformat` with opam, doesn't work with nix for some reason
    ];
  };

  programs.git = {
    enable = true;
    # Enhanced diffs
    delta.enable = true;
    ignores = [ ".DS_Store" ".direnv/" ".envrc" ];

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
      cm = "commit -m";
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

  # TODO: Re-enable this
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
        du-dust# fancy version of `du`
        eza# fancy version of `ls`
        fzf
        fd# fancy version of `find`
        btop# fancy version of `top`
        ripgrep# better version of `grep`
        diff-so-fancy# used for `git diff`
        fq
        jq
        yq
        jnv
        # tailspin # broken for some reason
        tmux-xpanes
        csvlens
        pup
        rabbitmq-server
        # opam #Ocaml 
        # easyrsa
        ;

      # Kensho stuff
      inherit (pkgs)
        awscli
        aws-iam-authenticator
        # TODO: add overlay to remove `jsonnet`, jrsonnet exports the same binary
        # go-jsonnet#ships with jsonnetfmt (issue with `jsonnet` build)
        jsonnet
        jrsonnet# is _blazingling_ fast
        jsonnet-bundler
        okta-aws-cli
        # grizzly # grafana cli
        # atuin #shell history
        sqlcmd
        prettierd
        ;

      # Dev stuff
      inherit (pkgs)
        go# Required for jsonnet-language-server
        cargo# Required for rnix-ls
        pipx
        python310
        luajit
        uv
        ;

      # Useful nix related tools
      inherit (pkgs)
        cachix# adding/managing alternative binary caches hosted by Cachix
        comma# run software from without installing it
        nix-output-monitor# get additional information while building packages
        nix-tree# interactively browse dependency graphs of Nix derivations
        nix-update# swiss-knife for updating nix packages
        statix# lints and suggestions for the Nix programming language
        ;

    } // lib.optionalAttrs pkgs.stdenv.isDarwin {
      inherit (pkgs)
        # m-cli # useful macOS CLI commands
        ;
    }) ++ [ pkgs.postgresql_16.dev pkgs.openssl.dev pkgs.openssl ];
}
