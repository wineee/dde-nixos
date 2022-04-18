{ stdenv
, lib
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "deepin-desktop-base";
  version = "2021.11.08";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-oGv7aTjjRQ/hF2T6lnNNXFWWb7w9ciQNCWpOB//Y38U=";
  };

  # nativeBuildInputs = [  ];

  makeFlags = [
    "DESTDIR=${placeholder "out"}"
  ];

  postInstall = ''
    # Remove Deepin distro's lsb-release
    rm $out/etc/lsb-release
    # Don't override systemd timeouts
    rm -r $out/etc/systemd
    # Remove apt-specific templates
    rm -r $out/usr/share/python-apt
  '';

  meta = with lib; {
    description = "Base assets and definitions for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/deepin-desktop-base";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
