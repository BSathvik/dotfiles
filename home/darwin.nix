{ config, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  inherit (config.home.user-info) nixConfigDirectory;
in
{
  xdg.configFile."aerospace".source = mkOutOfStoreSymlink "${nixConfigDirectory}/home/aerospace";
}
