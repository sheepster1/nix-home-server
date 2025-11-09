# This is my setup, but you will probably have to update a few things,
# Specifically, look at networking config, and disk config.
# My setup uses 192.168.0.122 as the server ip, and a /24 subnet
# Regarding disks, The OS is on an NVME (/dev/nvme0n1) and media + config is on an HDD (/dev/sda1)
{ config, lib, pkgs, ... }:

let
  serverIp = "192.168.0.122";
  serverNetmask = 24;
  serverHostname = "my-cluster";
in
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.systemd-boot.enable = true;
  boot.supportedFilesystems = [ "ntfs" ];

  fileSystems."/mnt/HDD" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  networking.interfaces."enp0s31f6".ipv4.addresses = [
    {
      address = serverIp;
      prefixLength = serverNetmask;
    }
  ];
  networking.defaultGateway = "192.168.0.1";
  networking.useDHCP = false;
  networking.nameservers = [
    "192.168.0.1"
    "8.8.8.8"
  ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    kompose
    kubectl
    kubernetes
    conntrack-tools
    openssl
    containerd
    ethtool
    socat
    cri-tools
    fluxcd
    k9s
    avahi
  ];

  system.stateVersion = "24.05";

  networking.extraHosts = "${serverIp} ${serverHostname}";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.firewall.allowedTCPPorts = [
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)

    # These are optional, but are needed if you want to host samba shares
    139  # Samba NetBIOS
    445  # Samba SMB/CIFS
  ];
  networking.firewall.allowedUDPPorts = [
    # These are optional, but are needed if you want to host samba shares
    137  # Samba NetBIOS Name Service
    138  # Samba NetBIOS Datagram Service
    3702 # WS-Discovery (Windows 10+ network discovery)
  ];
  services.k3s.enable = true;
  services.k3s.role = "server";
  services.k3s.extraFlags = toString [
    # "--debug" # Optionally add additional args to k3s
  ];

  environment.interactiveShellInit = ''
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
  '';

  # If you are planning on using ssh, you will need to uncomment the following block, to add your public key here
  # users.users.root = {
  #   openssh.authorizedKeys.keys = [
  #     "ssh-rsa <your-public-key>"
  #   ];
  # };

  # For now, this project uses only root, so these are needed
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
  # This is needed to allow the server to be discovered by other devices on the network, Again not requierd, but makes things easier
  services.avahi = {
          enable = true;
          nssmdns = true;
          openFirewall = true;
          publish = {
                  enable = true;
                  userServices = true;
                  addresses = true;
          };
  };
}
