{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, qt6
, fetchpatch
}:

stdenv.mkDerivation rec {
  pname = "dde-application-manager";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-n8ax87WSd5AWRvRP3/kWF1AoOhdVEFHh9mtwW7u+/Zg=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/linuxdeepin/dde-application-manager/commit/599506b57e6259970bab94ac5dce58e5a042ecb3.patch";
      hash = "sha256-oq7mKGyqFgpIHoLDTvGeUQTDY/0RYXOYJeeY+xB6On8=";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
  ];

  meta = with lib; {
    description = "Application manager for DDE";
    homepage = "https://github.com/linuxdeepin/dde-application-manager";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
