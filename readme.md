# My Nix Configs

![Build Nix envs](https://github.com/BSathvik/nixpkgs/workflows/Build%20Nix%20envs/badge.svg)

This repo contains my Nix configs for macOS configuration for most tools/programs I use, at least in the terminal.

## How to get this running

1. git clone into `~/.config/nixpkgs`
2. Edit the `primaryUserDefaults` in `flake.nix`

```
# this will pull in nix-darwin and setup stuff
nix build .#darwinConfigurations.bootstrap-x86.system

# to switch run
./result/sw/bin/darwin-rebuild switch --flake .#macOS
```

3. For homebrew to work, it needs to be installed separately and enable it `flake.nix`

4. you'll want to setup github public key using https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

## Troubleshooting

*Broken dawrin installation*: https://github.com/NixOS/nix/issues/2899#issuecomment-1669501326

