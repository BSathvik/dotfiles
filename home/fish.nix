{ pkgs, ... }:

{
  # Add Fish plugins
  home.packages = [
    pkgs.fishPlugins.async-prompt
    pkgs.fishPlugins.fzf-fish
    pkgs.babelfish
  ];

  # Fish Shell
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.fish.enable
  programs.fish = {
    enable = true;

    # Fish functions ----------------------------------------------------------------------------- {{{

    functions = {
      fish_prompt.body = ''
        if not set -q VIRTUAL_ENV_DISABLE_PROMPT
            set -g VIRTUAL_ENV_DISABLE_PROMPT true
        end

        set_color yellow

        set_color $fish_color_cwd
        printf '%s' (prompt_pwd)
        set_color normal

        set_color magenta
        printf '%s' (fish_vcs_prompt)
        set_color normal

        # Line 2
        echo
        if test -n "$VIRTUAL_ENV"
            printf "(%s) " (set_color blue)(basename $VIRTUAL_ENV)(set_color normal)
        end
        printf '↪ '
        set_color normal
      '';

      # fish_vcs_prompt_loading_indicator.body = ''
      #   echo (set_color brblack)…(set_color normal)
      # '';

      fish_jj_prompt.body = ''
        # Is jj installed?
        if not command -sq jj
            return 1
        end

        # Are we in a jj repo?
        if not jj root --quiet &>/dev/null
            return 1
        end

        # Generate prompt
        jj log --ignore-working-copy --no-graph --color always -r @ -T '
            surround(
                " (",
                ")",
                separate(
                    " ",
                    bookmarks.join(", "),
                    coalesce(
                        surround(
                            "\"",
                            "\"",
                            if(
                                description.first_line().substr(0, 24).starts_with(description.first_line()),
                                description.first_line().substr(0, 24),
                                description.first_line().substr(0, 23) ++ "…"
                            )
                        ),
                        "(no desc)"
                    ),
                    change_id.shortest(),
                    commit_id.shortest(),
                    if(conflict, "(conflict)"),
                    if(empty, "(empty)"),
                    if(divergent, "(divergent)"),
                    if(hidden, "(hidden)"),
                )
            )
        '
      '';

      fish_vcs_prompt.body = ''
        # If a prompt succeeded, we assume that it's printed the correct info.
        # This is so we don't try svn if git already worked.
        fish_jj_prompt $argv
        or fish_git_prompt $argv
        or fish_hg_prompt $argv
        or fish_fossil_prompt $argv
        # The svn prompt is disabled by default because it's quite slow on common svn repositories.
        # To enable it uncomment it.
        # You can also only use it in specific directories by checking $PWD.
        # or fish_svn_prompt
      '';

      gr.body = ''
        cd (git rev-parse --show-toplevel)
      '';

      rds-connect.body = ''
        set rds_suffix "cwzeyj7yzyfs.us-east-1.rds.amazonaws.com"
        set rds_host $argv[1]"."$rds_suffix
        set rds_user "sathvik_birudavolu"
        set password $(aws rds generate-db-auth-token --hostname $rds_host --port 5432 --region us-east-1 --username $rds_user)
        set -x PGPASSWORD $password
        psql "sslmode=require host=$rds_host user=$rds_user dbname=postgres"
      '';

      # Connect to AWS via Okta
      # Ops role only 1h session duration
      auth-codex.body = ''
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
                    --aws-iam-role arn:aws:iam::208007848330:role/kensho_developer
      '';

      kanagawa_theme.body = ''
        set -gx term_background dark

        # Kanagawa Fish shell theme
        # A template was taken and modified from Tokyonight:
        # https://github.com/folke/tokyonight.nvim/blob/main/extras/fish_tokyonight_night.fish
        set -l foreground DCD7BA normal
        set -l selection 2D4F67 brcyan
        set -l comment 727169 brblack
        set -l red C34043 red
        set -l orange FF9E64 brred
        set -l yellow C0A36E yellow
        set -l green 76946A green
        set -l purple 957FB8 magenta
        set -l cyan 7AA89F cyan
        set -l pink D27E99 brmagenta

        # Syntax Highlighting Colors
        set -g fish_color_normal $foreground
        set -g fish_color_command $cyan
        set -g fish_color_keyword $pink
        set -g fish_color_quote $yellow
        set -g fish_color_redirection $foreground
        set -g fish_color_end $orange
        set -g fish_color_error $red
        set -g fish_color_param $purple
        set -g fish_color_comment $comment
        set -g fish_color_selection --background=$selection
        set -g fish_color_search_match --background=$selection
        set -g fish_color_operator $green
        set -g fish_color_escape $pink
        set -g fish_color_autosuggestion $comment

        # Completion Pager Colors
        set -g fish_pager_color_progress $comment
        set -g fish_pager_color_prefix $cyan
        set -g fish_pager_color_completion $foreground
        set -g fish_pager_color_description $comment
      '';

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

      # Github Enterprise
      ghe = "GH_HOST=github.kensho.com ${pkgs.gh}/bin/gh";

      # https://github.com/jj-vcs/jj/issues/1841#issuecomment-1657464287
      j = "${jujutsu}/bin/jj --ignore-working-copy";

      # k8s
      kbh = "kubectl --context beta-hulk.kube.kensho.com";
      kbh-ns = "kubectl config set-context beta-hulk.kube.kensho.com --cluster=beta-hulk.kube.kensho.com --namespace";

      khc = "kubectl --context canary.hydra.kube.kensho.com";
      khc-ns = "kubectl config set-context canary.hydra.kube.kensho.com --cluster=canary.hydra.kube.kensho.com --namespace";

      khp = "kubectl --context prod.hydra.kube.kensho.com";
      khp-ns = "kubectl config set-context prod.hydra.kube.kensho.com --cluster=prod.hydra.kube.kensho.com --namespace";

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

      # Default kube editor
      set -gx KUBE_EDITOR nvim
      set -gx EDITOR nvim
      set -gx VISUAL nvim

      # Setup for pipx
      fish_add_path -ag ~/.local/bin
      fish_add_path -ag ~/.cargo/bin

      # Setup for psycopg2 build
      set -gx LIBRARY_PATH ${pkgs.openssl.out}/lib
      fish_add_path -pg ${pkgs.openssl.bin}/bin
      set -gx LDFLAGS "-L${pkgs.openssl.out}/lib"
      set -gx CPPFLAGS "-I${pkgs.openssl.dev}/include"

      # Setup for luarocks
      set -gx MY_LUA_PATH ${pkgs.luajit}

      # Setup harbor
      set -gx KD_REGISTRY_USER_NAME vik
      set -gx KD_HARBOR_PROJECT dev-sathvik-birudavolu
      # set -x KD_REGISTRY_CLI_SECRET get_this_from_harbor

      # Select the `kensho` AWS profile by default
      set -gx AWS_PROFILE kensho

      # OCaml Package Manager setup (Opam)
      test -r '/Users/bsat/.opam/opam-init/init.fish' && source '/Users/bsat/.opam/opam-init/init.fish' > /dev/null 2> /dev/null; or true

      set -g async_prompt_functions fish_vcs_prompt

      kanagawa_theme

      # fish_vi_key_bindings

      bind \co up-or-search
      bind \ci down-or-search
      # bind \cn accept-autosuggestion
      # bind \cp down-or-search
    '';
    # }}}
  };
}
# vim: foldmethod=marker
