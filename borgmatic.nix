{ ... }:

{
  services.borgmatic = {
    enable = true;
    settings = {
      location = {
        source_directories = [
          "/etc/nix"
          "/etc/nixos"
          "/home"
          "/boot"
          "/var/lib"
        ];
        exclude_patterns = [
          "/home/*/.cache/"
          "/home/*/.local/share/Trash/"
          "/home/*/.local/share/Steam/"
        ];
        repositories = [ "/data/backup/borg" ];
      };
      retention = {
        prefix = "{hostname}-";
        keep_daily = 7;
        keep_weekly = 4;
        keep_monthly = 12;
      };
      storage = {
        compression = "zstd";
        archive_name_format = "{hostname}-{now}";
      };
      consistency.checks = [{
        name = "disabled";
      }];
    };
  };
  # the timer shipped with borgmatic is not active
  systemd.timers.borgmatic = {
    enable = true;
    description = "timer to start borgmatic backup";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      Unit = "borgmatic.service";
      OnCalendar = "daily";
      Persistent = true;
      WakeSystem = true;
    };
  };
}
