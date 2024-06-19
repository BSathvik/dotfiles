{ nixpkgsDefaults
, nixpkgs-unstable
, nixpkgs-stable
, jrsonnet
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

  # We want the latest version of jrsonnet, it has a fix for a rendering issue
  # https://github.com/CertainLach/jrsonnet/issues/93
  jrsonnet = final: prev: {
    jrsonnet = jrsonnet.packages.${prev.system}.jrsonnet;
  };

  # neovim-unwrapped installs tree-sitter parsers that are added to the path that 
  # conflict with nvim-treesitter parser install starting v9.4
  # neovim-unwrapped = final: prev: {
  #   neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs {
  #     postInstall = ''
  #       rm -rf $out/lib/nvim/parser/*
  #     '';
  #   };
  # };
}
