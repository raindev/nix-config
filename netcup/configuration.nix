{ outputs, config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  nixpkgs.overlays = [ outputs.overlays.openssh ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "netcup";
  networking.interfaces.ens3.ipv6.addresses = [{
    address = "2a03:4000:2b:18b4::ff";
    prefixLength = 64;
  }];

  environment.systemPackages = with pkgs; [
    rustup
    # rustc relies on cc linker
    gcc
  ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "andrew@raindev.io";

  services.nginx = {
    enable = true;
    virtualHosts = {
      "lyze.app" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "/var/www/lyze/prod/";
        };
      };
      "api.lyze.app" = {
        forceSSL = true;
        enableACME = true;
        locations."/".return = "404";
        locations."/waitlist".proxyPass = "http://localhost:8002/waitlist";
        locations."/status".proxyPass = "http://localhost:8002/status";
      };
    };
  };

  systemd.services.lyze-waitlist-prod = {
    wantedBy = [ "multi-user.target" ];
    script = "/srv/lyze/prod/waitlist-service/service 1>>/var/lyze/prod/waitlist.txt";
  };

  system.stateVersion = "22.11";
}

