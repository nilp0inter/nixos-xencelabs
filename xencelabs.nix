{ pkgs, fetchzip, ... }:
let
  driversZipFile = fetchzip {
    url = "https://www.xencelabs.com/support/file/id/61/type/1";
    extension = "zip";
    sha256 = "sha256-FSxR7SekHqvvRXkNMcSpGumw8TTnRWGPP/N/rya1VOk=";
    stripRoot = true;
  };
in

pkgs.stdenv.mkDerivation rec {
  name = "xencelabs";
  version = "1.3.4-26";
  src = "${driversZipFile}/${name}-${version}.tar.gz";

  buildInputs = [ pkgs.libsForQt5.qt5.qtbase ];
  nativeBuildInputs = [ pkgs.libsForQt5.qt5.wrapQtAppsHook ];

  installPhase = ''
    # Copy udev rule
    mkdir -p $out/lib/udev/rules.d
    cp App/lib/udev/rules.d/10-xencelabs.rules $out/lib/udev/rules.d

    mkdir -p $out/share
    cp -R App/usr/share/applications $out/share

    mkdir -p $out/usr/share
    cp -R App/usr/share/icons $out/usr/share

    mkdir -p $out/usr/lib/xencelabs
    cp App/usr/lib/xencelabs/xencelabs $out/usr/lib/xencelabs
    cp -R App/usr/lib/xencelabs/config $out/usr/lib/xencelabs

    mkdir -p $out/bin
    ln -s $out/usr/lib/xencelabs/xencelabs $out/bin/xencelabs

  '';
  preFixup = let
    # we prepare our library path in the let clause to avoid it become part of the input of mkDerivation
    libPath = pkgs.lib.makeLibraryPath (with pkgs; [
      xorg.libXrandr               # libXrandr.so.2
      xorg.libX11                  # libX11.so.6
      xorg.libXtst                 # libXtst.so.6
      libsForQt5.qt5.qtx11extras   # libQt5X11Extras.so.5
      libsForQt5.qt5.qtsvg         # libQt5Svg.so.5
      libsForQt5.qt5.qtbase        # libQt5Widgets.so.5 libQt5Gui.so.5 libQt5Xml.so.5 libQt5Network.so.5 libQt5Core.so.5
      libglvnd                     # libGL.so.1
      stdenv.cc.cc.lib             # libstdc++.so.6
      libusb1                      # libusb-1.0.so.0
    ]);
  in ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}" \
      $out/usr/lib/xencelabs/xencelabs

    # fix the path in the desktop file
    substituteInPlace \
      $out/share/applications/xencelabs.desktop \
      --replace /usr/lib/xencelabs/xencelabs.sh $out/bin/xencelabs \
      --replace /usr/share/icons $out/usr/share/icons
  '';
}
