{ lib, pkgs, ... }:

{
  programs.fzf = {
    enableFishIntegration = true;
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    keyMode = "vi";
    terminal = "screen-256color";
    extraConfig = ''
      set -sg escape-time 10 

      set-option -g status-bg "#e82424"
      set-option -g status-fg "#19191F" 
      # pane border
      set-option -g pane-active-border-style fg="#e82424" #base01

      set -g window-status-format '#I:#(pwd="#{pane_current_path}"; echo ''${pwd####*/})#F'
      set -g window-status-current-format '#I:#(pwd="#{pane_current_path}"; echo ''${pwd####*/})#F'

      # status bar updates every 15s by default**, change to 1s here 
      set -g status-interval 5

      # Smart pane switching with awareness of Vim splits.
      # See: https://github.com/christoomey/vim-tmux-navigator
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
      tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
      if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
      if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R
      bind-key -T copy-mode-vi 'C-\' select-pane -l

      # Set new panes to open in current directory
      bind c new-window -c "#{pane_current_path}"
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
    '';
    plugins = with pkgs; [
      tmuxPlugins.cpu
      tmuxPlugins.extrakto
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '60' # minutes
        '';
      }
    ];
  };

  # Bat, a substitute for cat.
  # https://github.com/sharkdp/bat
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.bat.enable
  programs.bat.enable = true;
  programs.bat.config = {
    style = "plain";
  };

  # Direnv, load and unload environment variables depending on the current directory.
  # https://direnv.net
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.direnv.enable
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # SSH
  # https://nix-community.github.io/home-manager/options.html#opt-programs.ssh.enable
  # Some options also set in `../darwin/homebrew.nix`.
  programs.ssh.enable = true;
  programs.ssh.controlPath = "~/.ssh/%C"; # ensures the path is unique but also fixed length
  programs.ssh.matchBlocks = {
    "github.com" = {
      identityFile = "~/.ssh/github";
      extraOptions = {
        UseKeychain = "yes";
        AddKeysToAgent = "yes";
      };
    };
  };

  # Zoxide, a faster way to navigate the filesystem
  # https://github.com/ajeetdsouza/zoxide
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.zoxide.enable
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
        hyperfine# benchmarking tool
        parallel# runs commands in parallel
        ripgrep# better version of `grep`
        tealdeer# rust implementation of `tldr`
        diff-so-fancy# used for `git diff`
        ;

      # Kensho stuff
      inherit (pkgs)
        aws-iam-authenticator
        jsonnet# ships with jsonnetfmt
        jrsonnet# is _blazingling_ fast
        ;

      # Dev stuff
      inherit (pkgs)
        jq
        nodejs
        poetry
        go# Required for jsonnet-language-server
        cargo# Required for rnix-ls
        rustc
        rustfmt
        nixpkgs-fmt
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
    (pkgs.python39.withPackages (ps: with ps; [ pipx black pynvim ]))
  ];
}
