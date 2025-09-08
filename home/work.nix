{ pkgs, lib, ... }:
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
    index-url = "https://pypi.beta-p.kensho.com/simple/";
  };

  home.packages = lib.attrValues {
    # Some basics
    inherit (pkgs)
      rabbitmq-server
      awscli
      aws-iam-authenticator
      # TODO: add overlay to remove `jsonnet`, jrsonnet exports the same binary
      go-jsonnet#ships with jsonnetfmt (issue with `jsonnet` build)
      jsonnet
      jrsonnet# is _blazingling_ fast
      jsonnet-bundler
      okta-aws-cli
      grizzly# grafana cli
      atuin#shell history
      sqlcmd
      prettierd
      ;
  };
