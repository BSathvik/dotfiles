{ config, lib, pkgs, ... }:

let
  inherit (lib) elem optionalString;
in

{
  # Add Fish plugins
  home.packages = [
    pkgs.fishPlugins.fzf-fish
    pkgs.fishPlugins.hydro
    pkgs.babelfish
  ];

  # Fish Shell
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.fish.enable
  programs.fish = {
    enable = true;

    # Fish functions ----------------------------------------------------------------------------- {{{

    functions = {
      gr.body = ''
        cd (git rev-parse --show-toplevel)
      '';

      awsudo.body = ''
        read -P "Token: " token_code
        set credentials $(aws sts assume-role \
                        --role-arn arn:aws:iam::208007848330:role/kensho-operations-staff \
                        --role-session-name=terraform \
                        --serial-number=arn:aws:iam::208007848330:mfa/sathvik_birudavolu \
                        --token-code=$token_code)
    
        set -gx AWS_ACCESS_KEY_ID $(echo $credentials | jq -r ".Credentials.AccessKeyId")
        set -gx AWS_SECRET_ACCESS_KEY $(echo $credentials | jq -r ".Credentials.SecretAccessKey")
        set -gx AWS_SESSION_TOKEN $(echo $credentials | jq -r ".Credentials.SessionToken")
        aws sts get-caller-identity
      '';

      rds-connect.body = ''
        set rds_suffix "cwzeyj7yzyfs.us-east-1.rds.amazonaws.com"
        set rds_host "codex-app-dev."$rds_suffix
        set rds_user "codex-app"
        set password $(aws rds generate-db-auth-token --hostname $rds_host --port 5432 --region us-east-1 --username $rds_user)
        set -x PGPASSWORD $password
        psql "sslmode=require host=$rds_host user=$rds_user dbname=postgres"
      '';

      # Connect to AWS via Okta
      # Ops role only 1h session duration
      auth.body = ''
        okta-aws-cli \
                    --org-domain=kensho.okta.com \
                    --oidc-client-id=0oacyf7evwyrXjjgO4x7 \
                    --aws-acct-fed-app-id=0oa92bduvp33uw5Pv4x7 \
                    --open-browser \
                    --write-aws-credentials \
                    --cache-access-token \
                    --session-duration 36000 \
                    --profile kensho \
                    --aws-iam-role arn:aws:iam::208007848330:role/kensho_codex_developer
      '';

      auth-infra.body = ''
        okta-aws-cli \
                    --org-domain=kensho.okta.com \
                    --oidc-client-id=0oacyf7evwyrXjjgO4x7 \
                    --aws-acct-fed-app-id=0oa92bduvp33uw5Pv4x7 \
                    --open-browser \
                    --write-aws-credentials \
                    --cache-access-token \
                    --session-duration 3600 \
                    --profile kensho \
                    --aws-iam-role arn:aws:iam::208007848330:role/kensho_infra_developer
      '';

      # Sets Fish Shell to light or dark colorscheme based on `$term_background`.
      # set-shell-colors = {
      #   body = ''
      #     # Set LS_COLORS
      #     set -xg LS_COLORS (${pkgs.vivid}/bin/vivid generate solarized-$term_background)
      #
      #     # Set color variables
      #     if test "$term_background" = light
      #       set emphasized_text  brgreen  # base01
      #       set normal_text      bryellow # base00
      #       set secondary_text   brcyan   # base1
      #       set background_light white    # base2
      #       set background       brwhite  # base3
      #     else
      #       set emphasized_text  brcyan   # base1
      #       set normal_text      brblue   # base0
      #       set secondary_text   brgreen  # base01
      #       set background_light black    # base02
      #       set background       brblack  # base03
      #     end
      #
      #     # Set Fish colors that change when background changes
      #     set -g fish_color_command                    $emphasized_text --bold  # color of commands
      #     set -g fish_color_param                      $normal_text             # color of regular command parameters
      #     set -g fish_color_comment                    $secondary_text          # color of comments
      #     set -g fish_color_autosuggestion             $secondary_text          # color of autosuggestions
      #     set -g fish_pager_color_prefix               $emphasized_text --bold  # color of the pager prefix string
      #     set -g fish_pager_color_description          $selection_text          # color of the completion description
      #     set -g fish_pager_color_selected_prefix      $background
      #     set -g fish_pager_color_selected_completion  $background
      #     set -g fish_pager_color_selected_description $background
      #   '' + optionalString (elem pkgs.bottom config.home.packages) ''
      #     # Use correct theme for `btm`.
      #     if test "$term_background" = light
      #       alias btm "btm --color default-light"
      #     else
      #       alias btm "btm --color default"
      #     end
      #   '' + optionalString config.programs.neovim.enable ''
      #     # TODO: This ain't workin
      #     # Set `background` of all running Neovim instances.
      #     # for server in (${pkgs.neovim-remote}/bin/nvr --serverlist)
      #     #   ${pkgs.neovim-remote}/bin/nvr -s --nostart --servername $server \
      #     #     -c "set background=$term_background" &
      #     # end
      #   '';
      #   onVariable = "term_background";
      # };
    };
    # }}}

    # Fish configuration ------------------------------------------------------------------------- {{{

    # Aliases
    shellAliases = with pkgs; {
      ".." = "cd ..";
      cat = "${bat}/bin/bat";
      du = "${du-dust}/bin/dust";
      g = "${gitAndTools.git}/bin/git";
      ls = "${eza}/bin/eza";

      # k8s
      kbh = "kubectl --context beta-hulk.kube.kensho.com";
      kbh-ns = "kubectl config set-context beta-hulk.kube.kensho.com --cluster=beta-hulk.kube.kensho.com --namespace";

      kt = "kubectl --context test.kube.kensho.com";
      kt-ns = "kubectl config set-context test.kube.kensho.com --cluster=test.kube.kensho.com --namespace";
    };

    # Configuration that should be above `loginShellInit` and `interactiveShellInit`.
    shellInit = ''
      set -U fish_term24bit 1
    '';

    interactiveShellInit = ''
      set -g fish_greeting ""

      # fzf_configure_bindings --history=
      fzf_configure_bindings --directory=\cs --variables=\e\cv

      bind \co up-or-search
      bind \ci down-or-search

      # Default kube editor
      set -gx KUBE_EDITOR nvim
      set -gx EDITOR nvim
      set -gx VISUAL nvim

      # Setup for pipx
      fish_add_path -ag ~/.local/bin
      fish_add_path -ag ~/.cargo/bin

      # Setup for luarocks
      set -gx MY_LUA_PATH ${pkgs.luajit}

      # Setup harbor
      set -gx KD_REGISTRY_USER_NAME vik
      set -gx KD_HARBOR_PROJECT dev-sathvik-birudavolu
      # set -x KD_REGISTRY_CLI_SECRET get_this_from_harbor

      # Select the `kensho` AWS profile by default
      set -gx AWS_PROFILE kensho

      set -gx term_background dark

      # Run function to set colors that are dependant on `$term_background` and to register them so
      # they are triggerd when the relevent event happens or variable changes.
      # set-shell-colors

      # Set Fish colors that aren't dependant the `$term_background`.
      set -g fish_color_quote        cyan      # color of commands
      set -g fish_color_redirection  brmagenta # color of IO redirections
      set -g fish_color_end          blue      # color of process separators like ';' and '&'
      set -g fish_color_error        red       # color of potential errors
      set -g fish_color_match        --reverse # color of highlighted matching parenthesis
      set -g fish_color_search_match --background=yellow
      set -g fish_color_selection    --reverse # color of selected text (vi mode)
      set -g fish_color_operator     green     # color of parameter expansion operators like '*' and '~'
      set -g fish_color_escape       red       # color of character escapes like '\n' and and '\x70'
      set -g fish_color_cancel       red       # color of the '^C' indicator on a canceled command
    '';
    # }}}
  };
}
# vim: foldmethod=marker
