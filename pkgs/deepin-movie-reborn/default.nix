{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtkcommon
, dtkcore
, dtkgui
, dtkwidget
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, qtmpris
, qtdbusextended
, cmake
, pkgconfig
, qttools
, qtx11extras
, wrapQtAppsHook
, gsettings-qt
, ffmpeg
, ffmpegthumbnailer
, mpv
, xorg
, libdvdread
, libdvdnav
, libva
, glib
, gsettings-desktop-schemas
, wrapGAppsHook
, gtest
}:

stdenv.mkDerivation rec {
  pname = "deepin-movie-reborn";
  version = "5.9.14";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-crTAXTuStA3euPvq/h97wzuG+wTz83biqXgvxkERLRg=";
  };

  nativeBuildInputs = [
    cmake
    pkgconfig
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkcommon
    dtkcore
    dtkgui
    dtkwidget
    qtx11extras
    qtdbusextended
    qtmpris
    gsettings-qt
    ffmpeg
    ffmpegthumbnailer
    xorg.libXtst
    xorg.libXdmcp
    libdvdread
    libdvdnav
    libva
    mpv
    gsettings-desktop-schemas
    gtest
  ];

  patches = [
    ./fix-build.patch
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
    "--prefix XDG_DATA_DIRS : ${placeholder "out"}/share/gsettings-schemas/${pname}-${version}"
  ];

  fixCodePatch = ''

    substituteInPlace src/common/diskcheckthread.cpp \
      --replace "</usr/include/linux/cdrom.h>" "<linux/cdrom.h>"

    substituteInPlace tests/deepin-movie-platform/CMakeLists.txt \
      --replace "find_package(gui-private)" ""
    substituteInPlace tests/deepin-movie/CMakeLists.txt \
      --replace "find_package(gui-private)" ""
    substituteInPlace src/CMakeLists.txt \
      --replace "find_package(gui-private)" ""
  '';

  fixInstallPatch = ''
    substituteInPlace src/CMakeLists.txt \
      --replace "/usr/share/glib-2.0/schemas)" "$out/share/glib-2.0/schemas)" \
      --replace "/usr/share/deepin-manual/manual-assets/application/)" "$out/share/deepin-manual/manual-assets/application/)"
  '';

  postPatch = fixCodePatch + fixInstallPatch;

  preFixup = ''
    glib-compile-schemas ${glib.makeSchemaPath "$out" "${pname}-${version}"}
  '';

  meta = with lib; {
    description = "A full-featured video player supporting playing local and streaming media in multiple video formats";
    homepage = "https://github.com/linuxdeepin/deepin-movie-reborn";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
