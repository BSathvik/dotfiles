{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    keyMode = "vi";
    terminal = "screen-256color";
    extraConfig = ''
      set -sg escape-time 10 

      set-option -g status-bg "#E82424"
      set-option -g status-fg "#FFFFFF" 
      # pane border
      set-option -g pane-active-border-style fg="#E82424" #base01

      # set-option -g status-interval 5
      set-option -g automatic-rename on
      set-option -g automatic-rename-format '#{b:pane_current_path}'
      set -gu default-command
      set -g default-shell "$SHELL"
      # set-option -g default-shell ${pkgs.fish}/bin/fish

      # set -g window-status-format '#I:#(pwd="#{pane_current_path}"; echo ''${pwd####*/})#F'
      # set -g window-status-current-format '#I:#(pwd="#{pane_current_path}"; echo ''${pwd####*/})#F'

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

      bind-key -n 'C-8' previous-window
      bind-key -n 'C-9' next-window

      # Set new panes to open in current directory
      bind c new-window -c "#{pane_current_path}"
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      set-option -g renumber-windows on


      ##################### Basic Tmux Sessions #####################
      new -d -A -s personal -c ~/Documents/gdrive/notes
      neww -d -c ~/.config/nixpkgs

      new -A -s look -c ~/Documents/zen/look
      new -A -s work -c ~/Documents/zen
    '';
    plugins = with pkgs; [
      tmuxPlugins.extrakto
      {
        plugin = tmuxPlugins.tmux-thumbs;
        # set -g @thumbs-regexp-1 '([a-z0-9-]+)[ ]+[0-9]+' # Match kube resources
        extraConfig = ''
          set -g @thumbs-command 'echo -n {} | pbcopy'
        '';
      }
    ];
  };
}
