{ stdenv
, lib
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
  pname = "deepin-desktop-base";
  version = "2022.03.07";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-joAduRI9jUtPA4lNsEhgOZlci8j/cvD8rJThqvj6a8A=";
  };

  makeFlags = [ "DESTDIR=${placeholder "out"}" ];

  distribution_info = ''
    [Distribution]
    Name=NixOS
    WebsiteName=www.nixos.org
    Website=https://www.nixos.org
    Logo=${placeholder "out"}/share/pixmaps/nixos.svg
    LogoLight=${placeholder "out"}/share/pixmaps/nixos.svg
    LogoTransparent=${placeholder "out"}/share/pixmaps/nixos-white.svg
  '';

  postInstall = ''
    rm $out/etc/lsb-release
    rm -r $out/etc/systemd
    rm -r $out/usr/share/python-apt
    rm -r $out/usr/share/plymouth
    rm -r $out/usr/share/distro-info
    mv $out/usr/* $out/

    install -D ${./nixos.svg} $out/share/pixmaps/nixos.svg
    install -D ${./nixos-white.svg} $out/share/pixmaps/nixos-white.svg

    echo -e ${lib.escapeShellArg distribution_info} > $out/share/deepin/distribution.info
    ln -s $out/lib/deepin/desktop-version $out/etc/deepin-version
  '';

  meta = with lib; {
    description = "Base assets and definitions for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/deepin-desktop-base";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
