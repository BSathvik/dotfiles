{ pkgs ? import <nixpkgs> { } }:
let
  zentreefish = builtins.fetchGit {
    url = "git@github.kensho.com:kensho/zentreefish.git";
    ref = "master";
    rev = "09cce841881c0f12063cf664e70e01f35c6e78cc";
  };
in
pkgs.poetry2nix.mkPoetryApplication {
  # src = zentreefish;
  projectDir = "/Users/sathvikbirudavolu/Documents/zen/misc/projects/kensho-deploy";
  python = pkgs.python39;
  preferWheels = true;
  doCheck = false;
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
}
