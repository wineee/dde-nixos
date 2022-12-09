{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtk
, qt5integration
, qt5platform-plugins
, udisks2-qt5
, gio-qt
, image-editor
, cmake
, pkg-config
, qttools
, wrapQtAppsHook
, glibmm
, freeimage
, opencv
, ffmpeg
, ffmpegthumbnailer
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "deepin-album";
  version = "5.10.9";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-S/oVRD72dtpnvfGV6YfN5/syrmWA44H/1BbmAe0xjAY=";
  };

  postPatch = ''
    substituteInPlace libUnionImage/CMakeLists.txt \
      --replace "/usr" "$out" \
    
    substituteInPlace src/CMakeLists.txt \
      --replace "set(PREFIX /usr)" "set(PREFIX $out)" \
      --replace "/usr/bin" "$out/bin" \
      --replace "/usr/share/deepin-manual/manual-assets/application/)" "share/deepin-manual/manual-assets/application/)"
  '';

  nativeBuildInputs = [ cmake pkg-config qttools wrapQtAppsHook ];

  buildInputs = [
    dtk
    udisks2-qt5
    gio-qt
    image-editor
    glibmm
    freeimage
    opencv
    ffmpeg
    ffmpegthumbnailer
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  meta = with lib; {
    description = "A fashion photo manager for viewing and organizing pictures";
    homepage = "https://github.com/linuxdeepin/deepin-album";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
