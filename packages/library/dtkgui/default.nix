{ stdenv
, lib
, fetchFromGitHub
, pkgconfig
, qmake
, qttools
, gtest
, wrapQtAppsHook
, librsvg
, lxqt
, dtkcore
, dtkcommon
}:

stdenv.mkDerivation rec {
  pname = "dtkgui";
  version = "5.5.25+";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "bdfcc85de9202ff4699878b6d418f8655abc2f6c";
    sha256 = "sha256-LBUkJlAb6Wwx/xxxFbrk70MxkMnU0J7np7K2Ayf8boA=";
  };

  nativeBuildInputs = [
    qmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkcore
    dtkcommon
    librsvg
    lxqt.libqtxdg
    gtest
  ];

  qmakeFlags = [
    "DTK_VERSION=${version}"
    "LIB_INSTALL_DIR=${placeholder "out"}/lib"
    "MKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs"
  ];

  meta = with lib; {
    description = "Deepin Toolkit, gui module for DDE look and feel";
    homepage = "https://github.com/linuxdeepin/dtkgui";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
