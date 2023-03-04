{ inputs, ... }:
{
  modifications = final: prev: {
   neovim = prev.neovim.override {
     viAlias = true;
     vimAlias = true;
   };
    # patch OpenSSH to create paren dir for forwarded sockets
    openssh = prev.openssh.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        (prev.fetchpatch {
          url = "https://github.com/raindev/openssh-portable/commit/723ff04a0ed78863ce7959a8f322ef0118100da4.patch";
          sha256 = "uhC+YRCgn8Z2iIhPGNJFq/iwQEU42NBEbtmEJMt4Ve4=";
        })
      ];
      # nixpkgs build from a release tarball which has configure prebuilt
      buildInputs = (prev.buildInputs or []) ++ [ prev.pkgs.autoreconfHook ];
      doCheck = false;
    });
  };

  # add an overlay for 22.05 available as pkgs.old
  packages-2205 = final: _prev: {
    old = import inputs.nixpkgs-small-2205 {
      system = final.system;
      config.allowUnfree = true;
    };
  };

}
