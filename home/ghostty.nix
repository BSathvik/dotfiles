{ pkgs, ... }:
{
  xdg.configFile."ghostty/config".text =
    ''
      command = ${pkgs.fish}/bin/fish -c "${pkgs.tmux}/bin/tmux attach || ${pkgs.tmux}/bin/tmux"
      click-repeat-interval = 600
      auto-update-channel = stable
      font-family = "JetBrainsMono Nerd Font"
    '';
}
