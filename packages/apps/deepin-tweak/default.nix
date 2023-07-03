{ lib
, stdenv
, fetchFromGitHub
, cmake
, qttools
, pkg-config
, wrapQtAppsHook
, dtkdeclarative
, gsettings-qt
}:

stdenv.mkDerivation rec {
  pname = "deepin-tweak";
  version = "1.2.2.999";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "deepin-tweak";
    rev = "1fd15685221355c638fd8a69d38781e31dc08c36";
    hash = "sha256-4iLVAvuGUJ/yg2x+rJWV/ijXxMyxYCsY1ryqO7xbTGQ=";
  };

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkdeclarative
    gsettings-qt
  ];

  meta = with lib; {
    description = "An advanced setting tool built on dtkdeclarative";
    homepage = "https://github.com/linuxdeepin/deepin-tweak";
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [ rewine ];
  };
}
