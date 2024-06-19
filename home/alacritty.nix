{ pkgs, ... }:

{
  # Alacritty terminal
  programs.alacritty.enable = true;

  programs.alacritty.settings = {
    shell = {
      program = "${pkgs.fish}/bin/fish";
      args = [ "-c" "${pkgs.tmux}/bin/tmux attach || ${pkgs.tmux}/bin/tmux" ];
    };
    env = {
      "TERM" = "xterm-256color";
    };

    window.startup_mode = "Maximized";
    window.decorations = "None";

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

    # Kanagawa Alacritty Colors (Dark Mode)
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

    # Kanagawa Alacritty Colors (Light Mode)
    # colors = {
    #   primary = {
    #     background = "#F2ECBC";
    #     foreground = "#54546D";
    #   };
    #
    #   normal = {
    #     black = "#090618";
    #     red = "#c34043";
    #     green = "#76946a";
    #     yellow = "#c0a36e";
    #     blue = "#7e9cd8";
    #     magenta = "#957fb8";
    #     cyan = "#6a9589";
    #     white = "#c8c093";
    #   };
    #
    #   bright = {
    #     black = "#727169";
    #     red = "#e82424";
    #     green = "#98bb6c";
    #     yellow = "#e6c384";
    #     blue = "#7fb4ca";
    #     magenta = "#938aa9";
    #     cyan = "#7aa89f";
    #     white = "#dcd7ba";
    #   };
    #
    #   selection = {
    #     background = "#2d4f67";
    #     foreground = "#c8c093";
    #   };
    # };

    # Alabaster (Light Mode)
    # https://github.com/alacritty/alacritty-theme/blob/master/themes/alabaster.toml

    # colors = {
    #   primary = {
    #     background = "#F7F7F7";
    #     foreground = "#434343";
    #   };
    #
    #   cursor = {
    #     text = "#F7F7F7";
    #     cursor = "#434343";
    #   };
    #
    #   normal = {
    #     black = "#000000";
    #     red = "#AA3731";
    #     green = "#448C27";
    #     yellow = "#CB9000";
    #     blue = "#325CC0";
    #     magenta = "#7A3E9D";
    #     cyan = "#0083B2";
    #     white = "#BBBBBB";
    #   };
    #
    #   bright = {
    #     black = "#777777";
    #     red = "#F05050";
    #     green = "#60CB00";
    #     yellow = "#FFBC5D";
    #     blue = "#007ACC";
    #     magenta = "#E64CE6";
    #     cyan = "#00AACB";
    #     white = "#FFFFFF";
    #   };
    # };
  };
}
# vim: foldmethod=marker
