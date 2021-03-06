{ pkgs, lib, config, ... }:

{
  imports =
    [
       <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ./modules/networking.nix
      ./modules/wifi.nix
      ./modules/buildmachine.nix
      ./modules/laptop.nix
      ./modules/resolved.nix
      ./modules/workstation.nix
      ./modules/base.nix
      ./modules/efi.nix
    ];


  boot = {
    kernelParams = [ "acpi_rev_override=1"];

    kernelModules = [ "kvm-intel" ];

    kernelPackages = pkgs.linuxPackagesFor pkgs.linux_4_16;

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      luks.devices = [
        {
          name = "root";
          device = "/dev/nvme0n1p2";
          preLVM = true;
          allowDiscards = true;
        }
      ];
    };
    extraModprobeConfig = ''
      options i915 enable_fbc=1
      options iwlwifi power_save=Y
      options iwldvm force_cam=N
    '';
  };

  networking.hostName = "xps15";

  i18n.consoleFont = "latarcyrheb-sun32";

  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
  };

  fonts.fontconfig.dpi = 168;
  services.xserver = {
    dpi = 168;
    displayManager.sessionCommands = ''
      xrdb -merge "${pkgs.writeText "xrdb.conf" ''
        Xcursor.theme: Vanilla-DMZ
        Xcursor.size: 48
      ''}"
    '';
  };

  services.transmission = {
    enable = true;
  };

  hardware.bumblebee = {
    enable = true;
    driver = "nvidia";
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/c73b976c-f863-4e0b-b509-23e1c0d11a1b";
      fsType = "btrfs";
      options = [ "subvol=@nixos" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/1AB0-19EF";
      fsType = "vfat";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/c73b976c-f863-4e0b-b509-23e1c0d11a1b";
      fsType = "btrfs";
      options = [ "subvol=@nixos_home" ];
    };

  fileSystems."/home/silvio/arch_home" =
    { device = "/dev/disk/by-uuid/c73b976c-f863-4e0b-b509-23e1c0d11a1b";
      fsType = "btrfs";
      options = [ "subvol=@root" ];
    };

  swapDevices = [{
    device = "/dev/disk/by-uuid/901a64b3-d8dc-4745-b3d7-cfca564b7c9c";
  }];

  system.stateVersion = "18.03"; # Did you read the comment?
  nix.maxJobs = lib.mkDefault 8;
}
