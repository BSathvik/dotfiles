{ lib, pkgs, ... }:
{
  home.pip = {
    enable = true;
    settings = {
      global = {
        index-url = https://pypi.beta-p.kensho.com/simple/;
      };
    };
  };
}
