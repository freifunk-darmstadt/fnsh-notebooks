{ config, lib, pkgs, ... }:
{

  networking.useNetworkd = true;
  networking.nftables.enable = true;

  networking.networkmanager.unmanaged = [
    "type:ethernet"
    "type:bridge"
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMiPPoELDHdbSRFIDU55751WYNh97bEgBKVEgx3aEvUzAAAACnNzaDp0b20tdjg= Tom-YubiKey5NFC-2"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJfwrD05VmFMorcHkXOnJqsEyougYiYAeg82zH8rw52+ aron@enif"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKYkU9Fla4gbEqj0nW2vSHQ8aVQM7RtB7E2ynAMU/rb7 ffda@tomh v1"
  ];

  systemd.network.networks."10-hardif" = {
    matchConfig = {
      Name = "en*";
    };
    networkConfig = {
      DHCP = "no";
      IPv6AcceptRA = false;
      LinkLocalAddressing = "no";
      Bridge = "${config.systemd.network.netdevs."71-br-main".netdevConfig.Name}";
    };
  };

  systemd.network.netdevs."71-br-main" = {
    netdevConfig = {
      Name = "br-main";
      Kind = "bridge";
    };
  };

  systemd.network.networks."71-br-main" = {
    matchConfig = {
      Name = "${config.systemd.network.netdevs."71-br-main".netdevConfig.Name}";
    };
    networkConfig = {
      DHCP = "yes";
      EmitLLDP = true;
      LLDP = true;
      IPv6AcceptRA = true;
      IPv6PrivacyExtensions = false;
    };
  };

  networking.firewall.extraInputRules = ''
    tcp dport 8443 counter accept
  '';

  virtualisation.incus.enable = true;
  virtualisation.incus.ui.enable = true;

}
