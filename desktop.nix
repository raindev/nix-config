{ ... }:

{
  # enable local network hostname resolution without relying on DNS
  services.avahi.nssmdns = true;
}
