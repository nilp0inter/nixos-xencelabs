# nixos-xencelabs

🚧This is a work in progress🚧

This flake allows you to use XenceLabs Linux Driver with NixOS.

Use as an input for your flake and import the module into your NixOS system configuration. Then you can set the option:

```
services.xencelabs.enable = true;
```

### Noob Guide

This is how I was able to get it working on my setup, I may not fully understand how to use a flake.nix, so hopefully someone can correct my usage if possible.

1. Download the `xencelabs.nix` file to your `/etc/nixos` folder.
2. Add the following to the top of your `configuration.nix`:
```
{ config, pkgs, ... }:

let
  ...
  xencelabsPackage = import /etc/nixos/xencelabs.nix { 
    inherit (pkgs) pkgs fetchzip; 
  };
  ...
in
```
3. Then add the package to your package list and the udev rule:
```
services.udev.packages = [ xencelabsPackage ];
environment.systemPackages = with pkgs; [
...
  xencelabsPackage
...
];
```
4. `nixos-rebuild switch` to install it (reboot recommended for the udev rules)!
