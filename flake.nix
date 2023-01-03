{
  description = "Unofficial NixOS & Home Manager modules for Xencelabs";

  outputs = { self, nixpkgs }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    nixosModules.xencelabs = ./nixos.nix;

    packages.x86_64-linux.xencelabs = pkgs.libsForQt5.callPackage ./xencelabs.nix {};

    packages.x86_64-linux.default = self.packages.x86_64-linux.xencelabs;

  };
}
