{ outputs, inputs, config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  nixpkgs = {
    overlays = [
      outputs.overlays.openssh
      outputs.overlays.packages-2205
    ];
  };

  networking.hostId = "1bea433d";
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.kernelParams = [
    # systemd-gpt-auto-generator to fail, likely tripping over ZFS disks
    # https://github.com/NixOS/nixpkgs/issues/35681#issuecomment-370202008
    "systemd.gpt_auto=0"
  ];

  networking.hostName = "pi4";
  networking.interfaces.eth0.useDHCP = true;
  networking.firewall.enable = false;

  services = {
    zfs = {
      autoScrub = {
        enable = true;
        interval = "monthly";
      };
      # requires com.sun:auto-snapshot=true ZFS property to be set
      autoSnapshot.enable = true;
    };
    nfs.server = {
      enable = true;
      exports = ''
        /data 192.168.2.0/24(rw,sync,no_subtree_check)
        /data/archive 192.168.2.0/24(rw,sync,no_subtree_check)
        /data/backup 192.168.2.0/24(rw,sync,no_root_squash,no_subtree_check)
        /data/media 192.168.2.0/24(rw,sync,no_subtree_check)
        /data/sync 192.168.2.0/24(rw,sync,no_subtree_check)

        /external 192.168.2.0/24(rw,sync,no_subtree_check)
      '';
    };
    samba = {
      enable = true;
      shares = {
        data = {
          browsable = "yes";
          "read only" = "no";
          "valid users" = "raindev";
          path = "/data";
        };
      };
    };
    syncthing = {
      enable = true;
      user = "raindev";
      dataDir = "/home/raindev";
      guiAddress = "0.0.0.0:8384";
      extraOptions = {
        gui = {
          user = "andrew";
          password = "Do not touch my files!";
          tls = true;
        };
      };
    };
    plex.enable = true;
    plex.package = pkgs.old.plex;
    netatalk = {
      enable = true;
      settings = {
        TimeMachine = {
          path = "/data/backup/time-machine";
          "time machine" = "yes";
          "vol size limit" = 500000;
          #"valid users" = "raindev";
        };
      };
    };
    avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };
    prometheus = {
      enable = true;
      retentionTime = "5y";
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [
            "ethtool"
            "mountstats"
            "systemd"
          ];
        };
      };
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = [ "localhost:9100" ];
              labels = {
                instance = "localhost";
                job = "node";
              };
            }
          ];
        }
        {
          job_name = "prometheus";
          static_configs = [
            {
              targets = [ "localhost:9090" ];
              labels = {
                instance = "localhost";
                job = "prometheus";
              };
            }
          ];
        }
      ];
    };
    grafana = {
      enable = true;
      settings.server.http_addr = "0.0.0.0";
    };
  };
  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    # rpi-eeprom-update firmware update utility
    raspberrypi-eeprom
    # vcgencmd, e.g. to check for throttling
    libraspberrypi
    borgbackup
    borgmatic
    # for Lua JIT
    gcc
  ];

  services.cron = {
    enable = true;
    systemCronJobs = [
      "30 00 * * *  root	borgmatic --verbosity 1 2>&1 | logger -t borgmatic"
      "30 1 * * *  root	borgmatic --config /etc/borgmatic/config-sync.yaml --verbosity 1 2>&1 | logger -t borgmatic-sync"
      "30 2 * * 0  root     borgmatic --config /etc/borgmatic/config-data.yaml --verbosity 1 2>&1 | logger -t borgmatic-data"
    ];
  };

  environment.etc."borgmatic/config.yaml".source = ./borgmatic/config.yaml;
  environment.etc."borgmatic/config-sync.yaml".source = ./borgmatic/config-sync.yaml;
  environment.etc."borgmatic/config-data.yaml".source = ./borgmatic/config-data.yaml;

  system.stateVersion = "22.05";
}

