{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./local-config.nix
      ./incus.nix
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

  environment.systemPackages = with pkgs; [
    # editors
    nano
    vim
    emacs-nox

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
    man
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

    (pkgs.writeShellScriptBin "nixos-system-upgrade" ''
      export PATH="${pkgs.git}/bin:${pkgs.nixos-rebuild}/bin:$PATH"
      set -eo pipefail

      sudo echo -n "git: "
      sudo git -C /etc/nixos/ pull

      sudo nixos-rebuild switch --upgrade

      exit 0
    '')
  ];

  users.motd = ''
        · · · · · ·
     · · · · · · ·
     · · · · · Freifunk
         · × · Darmstadt
           · · ·

         · · ·
             ·
  '';


  programs.ssh.extraConfig = ''
    Host 192.168.0.1 192.168.1.1 192.168.8.1 192.168.88.1 192.168.1.254 192.168.1.20 fd01:67c:2ed8:10*::1:1
      StrictHostKeyChecking no
      UserKnownHostsFile /dev/null

    Host *
      LogLevel ERROR
      User root
  '';

  environment.shellAliases = {
    ssh_force_password = "ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no";
    scp_force_password = "scp -o PreferredAuthentications=password -o PubkeyAuthentication=no";
    sftp_force_password = "sftp -o PreferredAuthentications=password -o PubkeyAuthentication=no";
    ssh_stupid = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o VerifyHostKeyDNS=no";
    scp_stupid = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o VerifyHostKeyDNS=no";
    ssh_rsa = "ssh -o 'HostKeyAlgorithms +ssh-rsa' -o 'PubkeyAcceptedKeyTypes +ssh-rsa'";
    scp_rsa = "scp -o 'HostKeyAlgorithms +ssh-rsa' -o 'PubkeyAcceptedKeyTypes +ssh-rsa'";
    ssh_rsa_stupid = "ssh -o 'HostKeyAlgorithms +ssh-rsa' -o 'PubkeyAcceptedKeyTypes +ssh-rsa' -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o VerifyHostKeyDNS=no";
    scp_rsa_stupid = "scp -o 'HostKeyAlgorithms +ssh-rsa' -o 'PubkeyAcceptedKeyTypes +ssh-rsa' -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o VerifyHostKeyDNS=no";
    ssh_old = "ssh -o 'KexAlgorithms diffie-hellman-group1-sha1' -o 'HostKeyAlgorithms +ssh-dss' -o 'Ciphers aes128-cbc,3des-cbc'";
    ssh_old_stupid = "ssh -o 'KexAlgorithms diffie-hellman-group1-sha1' -o 'HostKeyAlgorithms +ssh-dss' -o 'Ciphers aes128-cbc,3des-cbc' -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o VerifyHostKeyDNS=no";
    scp_old_stupid = "scp -o 'KexAlgorithms diffie-hellman-group1-sha1' -o 'HostKeyAlgorithms +ssh-dss' -o 'Ciphers aes128-cbc,3des-cbc' -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o VerifyHostKeyDNS=no";
  };

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
}
