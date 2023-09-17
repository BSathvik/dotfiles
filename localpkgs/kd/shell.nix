let pkgs = import <nixpkgs> { };
in
let
  packageOverrides = pkgs.callPackage ./default.nix { };
  python = pkgs.python39.override { inherit packageOverrides; };
  pythonWithPackages = python.withPackages (ps: [ ps.kensho-deploy ]);
in
pkgs.mkShell {
  nativeBuildInputs = [ pythonWithPackages ];
}

