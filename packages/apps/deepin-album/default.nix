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
, pkgconfig
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
  version = "5.10.5";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-4IJoz7JRaiVfarkUD/05nJAKNeDXxK9wXar5eR5qC0s=";
  };

  patches = [
    (fetchpatch {
      name = "use_pkgconfig_to_find_libimageviewer";
      url = "https://github.com/linuxdeepin/deepin-album/commit/8a8ba283129e336b9598531505840ebf7f915e17.patch";
      sha256 = "sha256-YY1VahcXRgmbuUts6Oa5agyKznnf7bnaADA6iWj5rn4=";
    })
  ];

  postPatch = ''
    substituteInPlace libUnionImage/CMakeLists.txt \
      --replace "/usr" "$out" \
    
    substituteInPlace src/CMakeLists.txt \
      --replace "set(PREFIX /usr)" "set(PREFIX $out)" \
      --replace "/usr/bin" "$out/bin" \
      --replace "/usr/share/deepin-manual/manual-assets/application/)" "share/deepin-manual/manual-assets/application/)"
  '';

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
