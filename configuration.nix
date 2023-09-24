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
    extraGroups = [ "wheel" "wireshark" ];
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
    emacs-nox
    vim
    wget
    tmux
    ripgrep-all
    ripgrep
    picocom
    git
    firefox
    chromium
    htop
    tcpdump
    iw
    wireshark-qt
    magic-wormhole
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
    allowedTCPPorts = [ 80 ];
    allowedUDPPorts = [ 69 ];
  };

  system.copySystemConfiguration = true;
  system.stateVersion = "22.11"; # Did you read the comment?
}

