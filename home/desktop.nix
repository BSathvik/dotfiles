{ pkgs, ... }:

{
  home.packages = with pkgs; [
    tree
    _1password-gui
    xclip
    discord
    spotify
    # steam

    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    qbittorrent

    expressvpn
  ];

}
