{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "usb_storage" "uas" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "rpool/nixos/root";
      fsType = "zfs";
    };

  fileSystems."/var/lib" =
    {
      device = "rpool/nixos/var/lib";
      fsType = "zfs";
    };

  fileSystems."/var/log" =
    {
      device = "rpool/nixos/var/log";
      fsType = "zfs";
    };

  fileSystems."/home" =
    {
      device = "rpool/nixos/home";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/B680-8031";
      fsType = "vfat";
    };

  fileSystems."/external" =
    {
      device = "external";
      fsType = "zfs";
    };

  fileSystems."/data" =
    {
      device = "data";
      fsType = "zfs";
    };

  fileSystems."/data/backup" =
    {
      device = "data/backup";
      fsType = "zfs";
    };

  fileSystems."/data/media" =
    {
      device = "data/media";
      fsType = "zfs";
    };

  fileSystems."/data/archive" =
    {
      device = "data/archive";
      fsType = "zfs";
    };

  fileSystems."/data/sync" =
    {
      device = "data/sync";
      fsType = "zfs";
    };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
