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

  postInstall = ''
    rm $out/etc/lsb-release
    rm -r $out/etc/systemd
    rm -r $out/usr/share/python-apt
    rm -r $out/usr/share/plymouth
    rm -r $out/usr/share/distro-info
    mv $out/usr/* $out/
    rm -r $out/usr

    install -D ${./distribution_logo.svg} $out/share/pixmaps/distribution_logo.svg
    install -D ${./distribution_logo_light.svg} $out/share/pixmaps/distribution_logo_light.svg
    install -D ${./distribution_logo_transparent.svg} $out/share/pixmaps/distribution_logo_transparent.svg
    ln -s $out/lib/deepin/desktop-version $out/etc/deepin-version
  '';

  meta = with lib; {
    description = "Base assets and definitions for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/deepin-desktop-base";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
