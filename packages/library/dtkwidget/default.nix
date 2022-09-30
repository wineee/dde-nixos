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
  version = "5.6.2";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "bed17f106684a3ab8b0fff337fb850b8b31cf4f8";
    sha256 = "sha256-Jrf63j2lk7XR6mdF2fY3AxN1sgdBBHGdoJ9aU7eRk60=";
  };
 
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
