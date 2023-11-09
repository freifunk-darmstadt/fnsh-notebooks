{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  programs.wireshark.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  networking.hostName = "ffdatop";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  users.users.ffda = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "wireshark"
      "dialout"
    ];
  };

  services.xserver = {
    enable = true;
    displayManager = {
      gdm.enable = true;
      autoLogin = {
        enable = true;
	user = "ffda";
      };
    };
    desktopManager.gnome.enable = true;
  };
  

  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
  ]) ++ (with pkgs.gnome; [
    cheese # webcam tool
    gnome-music
    geary # email reader
    gnome-characters
    totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
  ]);

  
  environment.systemPackages = with pkgs; [
    # editors
    nano
    vim
    emacs-nox

    # gui editors
    gnome3.gedit
    jetbrains.pycharm-community
    vscodium

    # browsers
    chromium
    firefox

    # command line tools
    curl
    dmidecode
    ethtool
    (import ./ffda-network-setup-mode.nix)
    git
    gnupg
    htop
    iperf3
    iw
    jq
    lm_sensors
    magic-wormhole
    mtr
    pciutils
    picocom
    python3
    ripgrep
    ripgrep-all
    tcpdump
    tmate
    tmux
    usbutils
    unzip
    wget
    whois
    yq
    zip

    # gui system and debug tools
    gparted
    isoimagewriter
    wireshark-qt

    # media tools
    mpv
    vlc

    # office tools
    libreoffice
  ];

  services.atftpd = {
    enable = true;
    root = "/var/tftp";
  };

  services.nginx = {
    enable = true;
    virtualHosts.default = {
      root = "/var/tftp";
    };
  };

  services.fwupd.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 5201 ];
    allowedUDPPorts = [ 69 5201 ];
  };

  system.copySystemConfiguration = true;
  system.stateVersion = "22.11"; # Did you read the comment?
}

