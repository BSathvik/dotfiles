{ pkgs, ... }:
{
  packageOverrides = pkgs: rec {
    bat = pkgs.bat.overrideAttrs {
      version = "0.22.0";
    };
    # fishPlugins.fzf-fish = pkgs.fishPlugins.fzf-fish.overrideAttrs {
    #   checkPhase = ''
    #     # Disable git tests which inspect the project's git repo, which isn't
    #     # possible since we strip the impure .git from our build input
    #     rm -r tests/*git*
    #     rm -r tests/preview_changed_file/modified_path_with_spaces.fish
    #     rm -r tests/preview_changed_file/renamed_path_modifications.fish

    #     # Disable tests that are failing, probably because of our wrappers
    #     rm -r tests/configure_bindings
    #     rm -r tests/search_variables

    #     # Disable tests that are failing, because there is not 'rev' command
    #     rm tests/**
    #   '';
    # };
  };
}
