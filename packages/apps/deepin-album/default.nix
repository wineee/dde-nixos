{ stdenv
, lib
, fetchFromGitHub
, dtk
, qt5integration
, qt5platform-plugins
, udisks2-qt5
, gio-qt
, image-editor
, cmake
, pkgconfig
, qttools
, wrapQtAppsHook
, glibmm
, freeimage
, opencv
, ffmpeg
, ffmpegthumbnailer
}:

stdenv.mkDerivation rec {
  pname = "deepin-album";
  version = "5.10.2";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-F3s+smjKwY2ypGVsuA5OwR+a+ZnC7f4C7zpT3bTxtpw=";
  };

  nativeBuildInputs = [ cmake pkgconfig qttools wrapQtAppsHook ];

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
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  postPatch = ''
    substituteInPlace libUnionImage/CMakeLists.txt \
      --replace "set(PREFIX /usr)" "set(PREFIX $out)" \
    
    substituteInPlace src/CMakeLists.txt \
      --replace "set(PREFIX /usr)" "set(PREFIX $out)" \
      --replace "/usr/bin" "$out/bin" \
      --replace "/usr/share/deepin-manual/manual-assets/application/)" "share/deepin-manual/manual-assets/application/)"
  '';

  meta = with lib; {
    description = "A fashion photo manager for viewing and organizing pictures";
    homepage = "https://github.com/linuxdeepin/deepin-album";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
