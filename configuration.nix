# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "florina"; # Define your hostname.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Applying nixos-rebuild switch is causing issues with the network manager restarting
  # https://github.com/NixOS/nixpkgs/issues/180175#issuecomment-1658731959
  systemd.services.NetworkManager-wait-online = {
    serviceConfig = {
      ExecStart = [ "" "${pkgs.networkmanager}/bin/nm-online -q" ];
    };
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    useXkbConfig = true; # use xkb.options in tty.
  };

  fonts.packages = with pkgs; [
    recursive
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    dpi = 220;
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;

    # Configure keymap in X11
    xkb.layout = "us";
    xkb.options = "ctrl:swapcaps";

    # Load nvidia driver for Xorg and Wayland
    videoDrivers = [ "nvidia" ];
  };

  nix.settings = {
    # Use cachix build artifacts
    substituters = [
      "https://cache.nixos.org/"
      "https://bsathvik.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "bsathvik.cachix.org-1:mQrYap3jy3tUJFO9J0pflCJEm9r41CONF5vcNm7pK2U="
    ];

    trusted-users = [ "@admin" ];

    # https://github.com/NixOS/nix/issues/7273
    auto-optimise-store = false;

    experimental-features = [ "nix-command" "flakes" "ca-derivations" ];

    # Recommended when using `direnv` etc.
    keep-derivations = true;
    keep-outputs = true;
  };

  # Enable sound.
  hardware = {
    pulseaudio.enable = true;

    # Enable OpenGL
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    nvidia = {
      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
      # of just the bare essentials.
      powerManagement.enable = false;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of 
      # supported GPUs is at: 
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
      # Only available from driver 515.43.04+
      # Currently alpha-quality/buggy, so false is currently the recommended setting.
      open = false;

      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  # Required for nvidia drivers and other stuff
  nixpkgs.config.allowUnfree = true;

  programs.fish.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.florina = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.

    shell = pkgs.fish;

    packages = with pkgs; [
      firefox
      tree
      _1password-gui
      xclip
      discord
      spotify
      steam
    ];
  };

  services.jellyfin.enable = true;

  users.groups.media.members = [ "jellyfin" ];

  systemd.tmpfiles.settings = {
    "my-media" = {
      "/media".d = {
        mode = "0755";
        group = "media";
        user = "florina";
      };
    };
  };

  networking.firewall.enable = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    iputils
    git
    alacritty

    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    qbittorrent
    prowlarr

    expressvpn
  ];

  services.tailscale.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "yes";
  };

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
