{ pkgs ? import <nixpkgs> { } }:
let
  zentreefish = builtins.fetchGit {
    url = "git@github.kensho.com:kensho/zentreefish.git";
    ref = "master";
    rev = "09cce841881c0f12063cf664e70e01f35c6e78cc";
  };

  kdDeps = pkgs.poetry2nix.mkPoetryPackages {
    projectDir = "${zentreefish}/projects/kensho-deploy";
    python = pkgs.python39;
    preferWheels = true;
    overrides = pkgs.poetry2nix.overrides.withoutDefaults (
      self: super: {
        jsondiff = super.jsondiff.overridePythonAttrs (
          old: {
            buildInputs = (old.buildInputs or [ ]) ++ [ super.setuptools ];
          }
        );
        jsonnet = super.jsonnet.overridePythonAttrs (
          old: {
            buildInputs = (old.buildInputs or [ ]) ++ [ super.setuptools ];
          }
        );
        autoflake = super.autoflake.overridePythonAttrs (
          old: {
            buildInputs = (old.buildInputs or [ ]) ++ [ super.setuptools ];
          }
        );
        flake8-print = super.flake8-print.overridePythonAttrs (
          old: {
            buildInputs = (old.buildInputs or [ ]) ++ [ super.setuptools ];
          }
        );
      }
    );
  };

  kensho-deploy = pkgs.lib.findFirst (x: x.pname == "kensho-deploy") null kdDeps.poetryPackages;

in
pkgs.stdenv.mkDerivation {
  name = "kensho-deploy";
  phases = [ "installPhase" ];
  installPhase = ''mkdir -p "$out/bin"; ln -s ${kensho-deploy}/bin/kd "$out/bin/kd"'';
}
