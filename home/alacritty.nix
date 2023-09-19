{ lib, pkgs, ... }:

{
  # Alacritty terminal
  programs.alacritty.enable = true;

  programs.alacritty.settings = {
    shell = {
      program = "${pkgs.fish}/bin/fish";
      args = [ "-c" "${pkgs.tmux}/bin/tmux attach || ${pkgs.tmux}/bin/tmux" ];
      env = {
        "TERM" = "xterm-256color";
      };
    };

    window.startup_mode = "Fullscreen";

    font = {
      normal = {
        family = "JetBrainsMono Nerd Font";
        style = "Regular";
      };
      bold = {
        family = "JetBrainsMono Nerd Font";
        style = "Bold";
      };
      italic = {
        family = "JetBrainsMono Nerd Font";
        style = "Italic";
      };
      bold_italic = {
        family = "JetBrainsMono Nerd Font";
        style = "Bold Italic";
      };
      size = 15.0;
    };

    # Kanagawa Alacritty Colors
    colors = {
      primary = {
        background = "0x1f1f28";
        foreground = "0xdcd7ba";
      };

      normal = {
        black = "0x090618";
        red = "0xc34043";
        green = "0x76946a";
        yellow = "0xc0a36e";
        blue = "0x7e9cd8";
        magenta = "0x957fb8";
        cyan = "0x6a9589";
        white = "0xc8c093";
      };

      bright = {
        black = "0x727169";
        red = "0xe82424";
        green = "0x98bb6c";
        yellow = "0xe6c384";
        blue = "0x7fb4ca";
        magenta = "0x938aa9";
        cyan = "0x7aa89f";
        white = "0xdcd7ba";
      };

      selection = {
        background = "0x2d4f67";
        foreground = "0xc8c093";
      };
    };
  };
}
# vim: foldmethod=marker
