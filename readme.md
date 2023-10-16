# My Nix Configs

![Build Nix envs](https://github.com/BSathvik/nixpkgs/workflows/Build%20Nix%20envs/badge.svg)

This repo contains my Nix configs for macOS configuration for most tools/programs I use, at least in the terminal.

## How to get this running

1. Clone repo into `~/.config/nixpkgs`
2. Edit the `personalUser` in `flake.nix`
3. Build nix flake for macOS `x86_64-darwin` 
```
nix build .#darwinConfigurations.personalMac.system
```
4. Apply home-manager configuration
```
./result/sw/bin/darwin-rebuild switch --flake .#personalMac
```
5. Add SSH key `~/.ssh/github` for git authentication.

## What's in the box? 📦 

Configuration for neovim, tmux, fish, languages I use and their tools and some macOS settings.

#### neovim

I refuse to move my neovim config into nix 

## Extras

### Homebrew

For homebrew to work, it needs to be installed separately and enabled `flake.nix`

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

### Troubleshooting

*Broken dawrin installation*: https://github.com/NixOS/nix/issues/2899#issuecomment-1669501326

