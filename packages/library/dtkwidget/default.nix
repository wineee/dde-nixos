{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
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

  patches = [
    (fetchpatch {
      name = "chore(mkspecs): define mkspecs self";
      url = "https://github.com/linuxdeepin/dtkwidget/commit/f489687e3b4f0e1005dd10986e95acdfd0fd6a6c.patch";
      sha256 = "sha256-ZJ0LQeM8tx/ulafvu/kvPztqG08M2PzXhunuAqQYA+M=";
    })
  ];

  postPatch = ''
    substituteInPlace src/widgets/dapplication.cpp \
      --replace "auto dataDirs = DStandardPaths::standardLocations(QStandardPaths::GenericDataLocation);" \
                "auto dataDirs = DStandardPaths::standardLocations(QStandardPaths::GenericDataLocation) << \"$out/share\";"
  '';

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

  cmakeFlags = [ 
    "-DBUILD_DOCS=OFF"
    "-DMKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs/modules"
  ];

  meta = with lib; {
    description = "Deepin graphical user interface library";
    homepage = "https://github.com/linuxdeepin/dtkwidget";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
