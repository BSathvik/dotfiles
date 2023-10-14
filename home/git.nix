{ config, pkgs, ... }:

{
  # Git
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.git.enable
  programs.git.enable = true;

  programs.git.extraConfig = {
    diff.colorMoved = "default";
    pull.rebase = true;
  };

  programs.git.ignores = [
    ".DS_Store"
  ];

  programs.git.userEmail = config.home.user-info.email;
  programs.git.userName = config.home.user-info.fullName;

  # Enhanced diffs
  programs.git.delta.enable = true;

  programs.git.aliases = {
    # Basic commands
    a = "add";
    d = "diff";
    ds = "diff --staged";
    pl = "pull";
    pu = "push";
    s = "status";
    co = "checkout";
    cob = "checkout -b";
    com = "checkout master";
    cm = "commit -m";
    lg = "log --graph --abbrev-commit --decorate --format=format:'%C(blue)%h%C(reset) - %C(green)(%ar)%C(reset) %s %C(italic)- %an%C(reset)%C(magenta bold)%d%C(reset)' --all";
    rs = "restore --staged";
  };

  # GitHub CLI
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.gh.enable
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      editor = "nvim";
    };
  };
}
