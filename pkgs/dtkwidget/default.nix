{ stdenv
, lib
, fetchFromGitHub
, dtkcore
, dtkgui
, dtkcommon
, pkgconfig
, qmake
, qttools
, qtmultimedia
, qtsvg
, qtx11extras
, wrapQtAppsHook
, cups
, gtest
, gsettings-qt
, librsvg
, libstartup_notification
}:

stdenv.mkDerivation rec {
  pname = "dtkwidget";
  version = "5.5.44";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-qvALTSnebetvyKsBDDuV/PKzRnQLBaOUa4viPSyihS8=";
  };

  nativeBuildInputs = [
    qmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [
    qtmultimedia
    qtsvg
    qtx11extras

    cups
    gtest
    gsettings-qt
    librsvg
    libstartup_notification

    dtkcore
    dtkgui
    dtkcommon
  ];

  qmakeFlags = [
    "PREFIX=${placeholder "out"}"
    "LIB_INSTALL_DIR=${placeholder "out"}/lib"
    "INCLUDE_INSTALL_DIR=${placeholder "out"}/include"
    "MKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs"
  ];

  meta = with lib; {
    description = "Deepin graphical user interface library";
    homepage = "https://github.com/linuxdeepin/dtkwidget";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
