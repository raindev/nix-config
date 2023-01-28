# asc-key-to-qr-code-gif ran together with dependencies
{ pkgs ? import <nixpkgs> { } }:
with pkgs;
mkShell {
  name = "asc-key-to-qr-code-gif";
  packages = [ asc-key-to-qr-code-gif qrencode imagemagick zbar ];
}
