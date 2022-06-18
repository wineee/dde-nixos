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
  version = "5.5.46";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-iCbphW5tgtojM0G9DIt1k7YAoj2YQFx721z5+ADWy74=";
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

  fixTranslationPatch = ''
    substituteInPlace src/widgets/dapplication.cpp \
      --replace "auto dataDirs = DStandardPaths::standardLocations(QStandardPaths::GenericDataLocation);" "auto dataDirs = DStandardPaths::standardLocations(QStandardPaths::GenericDataLocation) << \"$out/share\";"
  '';

  postPatch = fixTranslationPatch;

  meta = with lib; {
    description = "Deepin graphical user interface library";
    homepage = "https://github.com/linuxdeepin/dtkwidget";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
