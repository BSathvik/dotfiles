{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.pip;
  iniFormat = pkgs.formats.ini { };
in
{
  options = {
    home.pip = {
      enable = mkEnableOption "pip.conf";

      settings = mkOption {
        type = iniFormat.type;
        default = { };
        example = literalExpression ''
          global = {
            timeout = 60;
            index-url = https://download.zope.org/ppix;
          };
        '';
        description = ''
          Configuration written to
          {file}`$XDG_CONFIG_HOME/pip/pip.conf`. See
          <https://pip.pypa.io/en/stable/topics/configuration/>
          for the default configuration.
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      xdg.configFile."pip/pip.conf" = mkIf (cfg.settings != { }) {
        source = iniFormat.generate "pip.conf" cfg.settings;
      };
    })
  ];
}
