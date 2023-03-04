{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/51a1013b-8543-45b9-ae0d-46a071d1856d";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-2c58bfa3-2e6d-4577-9e64-57708c703a32".device = "/dev/disk/by-uuid/2c58bfa3-2e6d-4577-9e64-57708c703a32";

  fileSystems."/boot/efi" =
    {
      device = "/dev/disk/by-uuid/CFF4-B2DF";
      fsType = "vfat";
    };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
