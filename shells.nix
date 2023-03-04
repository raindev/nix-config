{ pkgs ? import <nixpkgs> { } }: with pkgs; {

  # shell for bootstrapping flake-enabled nix and home-manager
  default = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "experimental-features = nix-command flakes";
    packages = [ nix home-manager git ];
  };

  # asc-key-to-qr-code-gif bundled with dependencies
  key-qr-gif = mkShell {
    packages = [ asc-key-to-qr-code-gif qrencode imagemagick zbar ];
  };

}
