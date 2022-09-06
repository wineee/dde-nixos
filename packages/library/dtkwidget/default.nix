{ stdenv
, lib
, fetchFromGitHub
, dtkcore
, dtkgui
, dtkcommon
, pkgconfig
, cmake
, qttools
, qtmultimedia
, qtsvg
, qtx11extras
, wrapQtAppsHook
, cups
, gsettings-qt
, librsvg
, libstartup_notification
, xorg
}:

stdenv.mkDerivation rec {
  pname = "dtkwidget";
  version = "5.6.1+";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "3102d4e6a60704901396d391b121ca07e65a6da9";
    sha256 = "sha256-TRG1W+8iSui8wO297AizIgVRJAiF7xVAHPO1dS8EyL4=";
  };

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkcore
    dtkgui
    dtkcommon
    qtmultimedia
    qtsvg
    qtx11extras
    cups
    gsettings-qt
    librsvg
    libstartup_notification
    xorg.libXdmcp
  ];

  fixTranslationPatch = ''
    substituteInPlace src/widgets/dapplication.cpp \
      --replace "auto dataDirs = DStandardPaths::standardLocations(QStandardPaths::GenericDataLocation);" "auto dataDirs = DStandardPaths::standardLocations(QStandardPaths::GenericDataLocation) << \"$out/share\";"
  '';

  postPatch = fixTranslationPatch;

  cmakeFlags = [ "-DBUILD_DOCS=OFF" ];

  meta = with lib; {
    description = "Deepin graphical user interface library";
    homepage = "https://github.com/linuxdeepin/dtkwidget";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
