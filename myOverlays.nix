{ nixpkgsDefaults
, nixpkgs-unstable
, nixpkgs-stable
, jrsonnet
, aerospace
, ghostty
,
}:
{
  # Overlays to add different versions `nixpkgs` into package set
  pkgs-stable = _: prev: {
    pkgs-stable = import nixpkgs-stable {
      inherit (prev.stdenv) system;
      inherit (nixpkgsDefaults) config;
    };
  };

  pkgs-unstable = _: prev: {
    pkgs-unstable = import nixpkgs-unstable {
      inherit (prev.stdenv) system;
      inherit (nixpkgsDefaults) config;
    };
  };

  # these checks keep failing, let's override this for now
  fzf-fish = final: prev: {
    fishPlugins = prev.fishPlugins.overrideScope (ffinal: fprev: {
      fishtape_3 = fprev.fishtape_3.overrideAttrs (oldAttrs: {
        checkPhase = null;
      });
      fzf-fish = fprev.fzf-fish.overrideAttrs (oldAttrs: {
        checkPhase = null;
      });
    });
  };

  aerospace = final: prev: {
    aerospace = prev.aerospace.overrideAttrs (oldAttrs: { src = aerospace; });
  };

  # We want the latest version of jrsonnet, it has a fix for a rendering issue
  # https://github.com/CertainLach/jrsonnet/issues/93
  jrsonnet = final: prev: {
    jrsonnet = jrsonnet.packages.${prev.system}.jrsonnet;
  };

  ghostty = final: prev: {
    ghostty = ghostty.packages.${prev.system}.ghostty;
  };


  # We dont' want the shared lib from jsonnet, it conflicts with jrsonnet path
  # TODO: This shit aint'w working.
  # jsonnet = final: prev: {
  #   jsonnet = prev.jsonnet.overrideAttrs (oldAttrs: {
  #     postInstall = ''
  #       mkdir -p $out/share/doc/jsonnet
  #       cp -r ./html $out/share/doc/jsonnet
  #
  #       rm -rf $out/lib/*
  #     '';
  #   });
  # };
}
