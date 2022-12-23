{ config, pkgs, lib, ... }:

{
  imports = [
    ./frame.work.nix
  ];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmpOnTmpfs = true;
  boot.tmpOnTmpfsSize = "8G";
  # Modules I want to ensure are there
  boot.initrd.availableKernelModules = [ "thunderbolt" "nvme" "usb_storage" "uas" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "coretemp" ];
  boot.extraModulePackages = [ ];
  # Frame.work needs latest kernel for BT and Wi-Fi to work.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "uranium";
  networking.useDHCP = false;

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/cbaf293c-c8dc-4586-ba65-73cff3f24468";
      fsType = "ext4";
    };
  boot.initrd.luks.gpgSupport = true;

  boot.initrd.luks.devices."luks".device = "/dev/disk/by-uuid/c2e5cd09-b5d7-42cb-a78a-f549edfa0eb4";

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/028E-BC0A";
      fsType = "vfat";
    };

  swapDevices = [ ];

  # This node was created in 21.11 days
  system.stateVersion = "21.11";

  # For brightness control
  users.users.spacecadet.extraGroups = [ "video" ];
  # bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  # pipewire config, from https://nixos.wiki/wiki/PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
    media-session.config.bluez-monitor.rules = [
      {
        # Matches all cards
        matches = [{ "device.name" = "~bluez_card.*"; }];
        actions = {
          "update-props" = {
            "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
            # mSBC is not expected to work on all headset + adapter combinations.
            "bluez5.msbc-support" = true;
            # SBC-XQ is not expected to work on all headset + adapter combinations.
            "bluez5.sbc-xq-support" = true;
          };
        };
      }
      {
        matches = [
          # Matches all sources
          { "node.name" = "~bluez_input.*"; }
          # Matches all outputs
          { "node.name" = "~bluez_output.*"; }
        ];
        actions = {
          "node.pause-on-idle" = false;
        };
      }
    ];
  };
  # battery management
  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = lib.mkDefault "powersave";
  };
  services.tlp.enable = true;
  # temperature management
  services.thermald.enable = true;
  environment.etc."sysconfig/lm_sensors".text = ''
    # Generated by sensors-detect on Mon Jan  3 23:34:14 2022
    # This file is sourced by /etc/init.d/lm_sensors and defines the modules to
    # be loaded/unloaded.
    #
    # The format of this file is a shell script that simply defines variables:
    # HWMON_MODULES for hardware monitoring driver modules, and optionally
    # BUS_MODULES for any required bus driver module (for example for I2C or SPI).

    HWMON_MODULES="coretemp"
  '';
  # Instead of archwiki, frame.work forums recommend this with s2idle

  # Hardware acceleration
  # Taken from https://nixos.wiki/wiki/Accelerated_Video_Playback
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
  services.fwupd = {
    enable = true;
    extraRemotes = [ "lvfs-testing" ];
  };
  environment.etc."fwupd/uefi_capsule.conf".text = lib.mkForce ''
    [uefi_capsule]
    OverrideESPMountPoint=/boot
    DisableCapsuleUpdateOnDisk=true
  '';
  # NOTE: fwupdmgr uses this to check the boot
  services.udisks2.enable = true;
  # NOTE: Wireless config is here for now, until refactoring of default.nix is done
  systemd.network.links."10-wifi-lan" = {
    matchConfig.PermanentMACAddress = "f8:b5:4d:d7:16:53";
    linkConfig.Name = "wifi-lan";
  };
}
