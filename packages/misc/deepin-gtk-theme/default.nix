{ stdenv
, lib
, fetchFromGitHub
, gtk-engine-murrine
}:

stdenv.mkDerivation rec {
  pname = "deepin-gtk-theme";
  version = "unstable-2022-06-27";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "deepin-gtk-theme";
    rev = "0c1a4b38a9fc525c577d472ba01530c42d8fb24e";
    sha256 = "sha256-XqIHJb58yhF0lktySVPTeuzktN+1MdprdBfgoWyinTQ=";
  };

  propagatedUserEnvPkgs = [
    gtk-engine-murrine
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  meta = with lib; {
    description = "Deepin GTK Theme";
    homepage = "https://github.com/linuxdeepin/deepin-gtk-theme";
    license = licenses.lgpl3Plus;
    platforms = platforms.unix;
    maintainers = [ maintainers.romildo ];
  };
}
