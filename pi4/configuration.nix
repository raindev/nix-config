# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  #nix.nixPath = [
  #  "nixpkgs=/home/raindev/code/nixpkgs"
  #  "nixos-config=/etc/nixos/configuration.nix"
  #];
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  # Run hardlink deduplication for nix store every night.
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 90d";
  };

  networking.hostId = "1bea433d";
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.kernelParams = [
    # systemd-gpt-auto-generator to fail, likely tripping over ZFS disks
    # https://github.com/NixOS/nixpkgs/issues/35681#issuecomment-370202008
    "systemd.gpt_auto=0"
  ];

  networking.hostName = "pi4";
  networking.wireless.enable = false;
  networking.interfaces.eth0.useDHCP = true;
  networking.firewall.enable = false;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";

  services = {
     zfs = {
       autoScrub = {
         enable = true;
	 interval = "monthly";
       };
       # requires com.sun:auto-snapshot=true ZFS property to be set
       autoSnapshot.enable = true;
     };
     #resolved.enable = true;
     nfs.server = {
       enable = true;
       exports = ''
         /data 192.168.2.0/24(rw,sync,no_subtree_check)
         /data/archive 192.168.2.0/24(rw,sync,no_subtree_check)
         /data/backup 192.168.2.0/24(rw,sync,no_root_squash,no_subtree_check)
         /data/media 192.168.2.0/24(rw,sync,no_subtree_check)
         /data/sync 192.168.2.0/24(rw,sync,no_subtree_check)
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
     openssh = {
       enable = true;
       permitRootLogin = "no";
       # Remove stale sockets on connect (for GPG socker forwarding)
       # https://wiki.archlinux.org/title/GnuPG#Forwarding_gpg-agent_and_ssh-agent_to_remote
       extraConfig = "StreamLocalBindUnlink yes";
       #passwordAuthentication = false;
     };
     syncthing = {
       enable = true;
       user = "raindev";
       dataDir = "/home/raindev";
       guiAddress = "0.0.0.0:8384";
       # TODO: remove once my patch is available
       overrideFolders = false;
       overrideDevices = false;
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
  users.users.raindev = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-linux";

  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    git
    wget
    tree
    exa
    nixos-option
    # rpi-eeprom-update firmware update utility
    raspberrypi-eeprom
    # vcgencmd, e.g. to check for throttling
    libraspberrypi
    borgbackup
    borgmatic
    gnupg
    gnumake
    # for Lua JIT
    gcc
  ];

  # GPG expects the agent socket to be in /run/user/1000/gnupg.
  # SSH however does not create a parent directory for forwarded sockets.
  systemd.services.gpg-socketdir = {
    script = "${pkgs.gnupg}/bin/gpgconf --create-socketdir";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "raindev";
    };
  };
  #programs.gnupg.agent = {
  #        enable = true;
  #        enableSSHSupport = true;
  #};

  environment.variables.EDITOR = "nvim";
  nixpkgs.overlays = [
    (self: super: {
       neovim = super.neovim.override {
	 viAlias = true;
	 vimAlias = true;
       };
     })
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

  system.stateVersion = "22.05"; # Did you read the comment?
}

