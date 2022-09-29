{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtkcore
, dtkgui
, dtkcommon
, pkg-config
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
  version = "5.6.1";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "1b42cb9c7dbd7c10c7f490373181aa80bebf6e72";
    sha256 = "sha256-iD9WIMeUCE8RL1QyIETj8owbSLVloz25X8W9mmYbK1I=";
  };
 
  patches = [
    (fetchpatch {
      name = "feat: Improve version information";
      url = "https://github.com/linuxdeepin/dtkwidget/commit/94444d442b2cdc62518c1d9938826035c741d18f.patch";
      sha256 = "sha256-a0YCQdkB62oN6G99mRS3xMpQ6QCSFNXwnGrNjOVze3M=";
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
    pkg-config
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
