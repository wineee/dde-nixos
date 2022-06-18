{ stdenv
, lib
, fetchFromGitHub
, pkgconfig
, qmake
, qttools
, gtest
, wrapQtAppsHook
, librsvg
, dtkcore
, dtkcommon
}:

stdenv.mkDerivation rec {
  pname = "dtkgui";
  version = "5.5.24";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-9zIqRDtjWYpj6n2gV7wrv35XrZnYiy+/6ZwyENNPUmY=";
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
