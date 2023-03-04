{ outputs, ... }:

{
  nixpkgs.overlays = [ outputs.overlays.modifications ];
  nixpkgs.config.allowUnfree = true;
}
