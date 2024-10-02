{ pkgs, ... }:
{
  xdg.configFile."pip/pip.conf".source = (pkgs.formats.ini { }).generate "pip.conf" {
    global = {
      index-url = "https://pypi.beta-p.kensho.com/simple/";
    };
  };

  xdg.configFile."uv/uv.toml".source = (pkgs.formats.toml { }).generate "uv.toml" {
    pip = {
      index-url = "https://pypi.beta-p.kensho.com/simple/";
    };
  };
}
