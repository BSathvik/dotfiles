# Inspired by: https://github.com/johbo/pip2nix-generated/blob/a690979bf5fb084fc21c04f7f039036dc5151067/devpi/default.nix#L1

{ pkgs ? (import <nixpkgs> {})
, pythonPackages ? "python39Packages"
}:

let
  inherit (pkgs.lib) fix extends composeExtensions composeManyExtensions;

  pythonPackagesGenerated = pkgs.callPackage ./python-packages.nix { };

  pythonPackagesLocalOverrides = self: super: {
    jsondiff = super.jsondiff.override (prev: {
      src = pkgs.fetchurl {
        url = "https://pypi.beta-p.kensho.com/api/package/jsondiff/jsondiff-${prev.version}.tar.gz";
        sha256 = "34941bc431d10aa15828afe1cbb644977a114e75eef6cc74fb58951312326303";
      };
      format = "setuptools";
    });

    rjsonnet = super.rjsonnet.override (prev: {
      src = pkgs.fetchurl {
        url = "https://pypi.beta-p.kensho.com/api/package/rjsonnet/rjsonnet-${prev.version}-cp37-abi3-macosx_10_9_x86_64.macosx_11_0_arm64.macosx_10_9_universal2.whl";
        sha256 = "20fc24d75fbd68f31423cbd7bbf0b9f52d3c27583d243fabac0ea1407a747ad7";
      };
      format = "wheel";
    });

    rpds-py = super.rpds-py.override (prev: {
      src = pkgs.fetchurl {
        url = "https://pypi.beta-p.kensho.com/api/package/rpds-py/rpds_py-${prev.version}-cp39-cp39-macosx_10_7_x86_64.whl"; 
        sha256 = "570cc326e78ff23dec7f41487aa9c3dffd02e5ee9ab43a8f6ccc3df8f9327623";
      };
      format = "wheel";
    });
  };

  mainPackage = self: super: {
    kensho-deploy = super.kensho-deploy.override (prev: {
      src = pkgs.fetchurl {
        url = "https://pypi.beta-p.kensho.com/api/package/kensho-deploy/kensho_deploy-${prev.version}-py3-none-any.whl";
        sha256 = "GLCRrBD7HpZHb8UYZ4Y03ok2ub2ZOpDs2Hnfy/W+fcA=";
      };
      format = "wheel";
    });
  };

in composeManyExtensions [ pythonPackagesGenerated pythonPackagesLocalOverrides mainPackage ]
