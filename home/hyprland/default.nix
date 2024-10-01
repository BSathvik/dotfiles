{ pkgs
, hyprland
, nur-ryan4yin
, ...
}:
let
  package = hyprland.packages.${pkgs.system}.hyprland;
in
{
  # NOTE: We have to enable hyprland/i3's systemd user service in home-manager,
  # so that gammastep/wallpaper-switcher's user service can be start correctly!
  # they are all depending on hyprland/i3's user graphical-session
  wayland.windowManager.hyprland = {
    inherit package;
    enable = true;
    settings = {
      source = "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-hyprland}/themes/mocha.conf";
      env = [
        "NIXOS_OZONE_WL,1" # for any ozone-based browser & electron apps to run on wayland
        "MOZ_ENABLE_WAYLAND,1" # for firefox to run on wayland
        "MOZ_WEBRENDER,1"
        # misc
        "_JAVA_AWT_WM_NONREPARENTING,1"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_QPA_PLATFORM,wayland"
        "SDL_VIDEODRIVER,wayland"
        "GDK_BACKEND,wayland"

        # for hyprland with nvidia gpu, ref https://wiki.hyprland.org/Nvidia/
        "LIBVA_DRIVER_NAME,nvidia"
        "XDG_SESSION_TYPE,wayland"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        # fix https://github.com/hyprwm/Hyprland/issues/1520
        "WLR_NO_HARDWARE_CURSORS,1"
        "HYPRCURSOR_SIZE,32"
      ];

      # Configure your Display resolution, offset, scale and Monitors here, use `hyprctl monitors` to get the info.
      #   highres:      get the best possible resolution
      #   auto:         postition automatically
      #   1.5:          scale to 1.5 times
      #   bitdepth,10:  enable 10 bit support
      monitor = [ ",3840x2160@60,auto,1.666667" "eDP-1,highres,auto,1.2,bitdepth,10" ];
    };

    extraConfig = builtins.readFile ./conf/hyprland.conf;
    # gammastep/wallpaper-switcher need this to be enabled.
    systemd.enable = true;
  };

  # NOTE: this executable is used by greetd to start a wayland session when system boot up
  # with such a vendor-no-locking script, we can switch to another wayland compositor without modifying greetd's config in NixOS module
  home.file.".wayland-session" = {
    source = "${package}/bin/Hyprland";
    executable = true;
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "~/.config/hypr/wallpapers/starship_day.png"
      ];
      wallpaper = [
        ",~/.config/hypr/wallpapers/starship_day.png"
      ];
      ipc = "on";
    };
  };

  # hyprland configs, based on https://github.com/notwidow/hyprland
  xdg.configFile = {
    "hypr/mako" = {
      source = ./conf/mako;
      recursive = true;
    };
    "hypr/wallpapers" = {
      source = ./conf/wallpapers;
      recursive = true;
    };
    "hypr/scripts" = {
      source = ./conf/scripts;
      recursive = true;
    };
    "hypr/waybar" = {
      source = ./conf/waybar;
      recursive = true;
    };
    "hypr/wlogout" = {
      source = ./conf/wlogout;
      recursive = true;
    };

    # music player - mpd
    "mpd" = {
      source = ./conf/mpd;
      recursive = true;
    };
  };

  # refer to https://codeberg.org/dnkl/foot/src/branch/master/foot.ini
  xdg.configFile."foot/foot.ini".text =
    ''
      [main]
      dpi-aware=yes
      font=JetBrainsMono Nerd Font:size=13
      shell=${pkgs.bash}/bin/bash --login -c 'nu --login --interactive'
      term=foot
      initial-window-size-pixels=3840x2160
      initial-window-mode=windowed
      pad=0x0                             # optionally append 'center'
      resize-delay-ms=10

      [mouse]
      hide-when-typing=yes
    ''
    + (builtins.readFile "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-foot}/catppuccin-mocha.conf");

  xdg.dataFile.icons = {
    source = ./conf/cursor;
    recursive = true;
  };

  programs = {
    # a wayland only terminal emulator
    foot = {
      enable = true;
      # foot can also be run in a server mode. In this mode, one process hosts multiple windows.
      # All Wayland communication, VT parsing and rendering is done in the server process.
      # New windows are opened by running footclient, which remains running until the terminal window is closed.
      #
      # Advantages to run foot in server mode including reduced memory footprint and startup time.
      # The downside is a performance penalty. If one window is very busy with, for example, producing output,
      # then other windows will suffer. Also, should the server process crash, all windows will be gone.
      server.enable = true;
    };

    # source code: https://github.com/nix-community/home-manager/blob/master/modules/programs/chromium.nix
    google-chrome = {
      enable = true;

      # https://wiki.archlinux.org/title/Chromium#Native_Wayland_support
      commandLineArgs = [
        "--ozone-platform-hint=auto"
        "--ozone-platform=wayland"
        # make it use GTK_IM_MODULE if it runs with Gtk4, so fcitx5 can work with it.
        # (only supported by chromium/chrome at this time, not electron)
        "--gtk-version=4"
        # make it use text-input-v1, which works for kwin 5.27 and weston
        "--enable-wayland-ime"

        # enable hardware acceleration - vulkan api
        # "--enable-features=Vulkan"
      ];
    };

    firefox = {
      enable = true;
      enableGnomeExtensions = false;
      package = pkgs.firefox-wayland; # firefox with wayland support
    };
  };

  home.packages = with pkgs; [
    waybar # the status bar
    hyprpaper # the wallpaper
    swayidle # the idle timeout
    swaylock # locking the screen
    wlogout # logout menu
    wl-clipboard # copying and pasting
    hyprpicker # color picker

    hyprshot # screen shot
    grim # taking screenshots
    slurp # selecting a region to screenshot
    wf-recorder # screen recording

    # Required for brightness/volume controls
    libnotify
    # To key keystrokes
    wev
    playerctl # looks like waybar uses it 
    tidal-hifi

    mako # the notification daemon, the same as dunst

    yad # a fork of zenity, for creating dialogs

    # audio
    alsa-utils # provides amixer/alsamixer/...
    mpd # for playing system sounds
    mpc-cli # command-line mpd client
    ncmpcpp # a mpd client with a UI
    networkmanagerapplet # provide GUI app: nm-connection-editor
    blueman
    pavucontrol
  ];

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      size = 32;
    };
  };
}
