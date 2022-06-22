{ stdenv
, lib
, fetchFromGitHub
, dtkcore
, dtkgui
, dtkwidget
, dtkcommon
, qt5integration
, qt5platform-plugins
, cmake
, qttools
, pkgconfig
, wrapQtAppsHook
, fontconfig
, freetype
, gtest
}:

stdenv.mkDerivation rec {
  pname = "deepin-font-manager";
  version = "5.9.11";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-S8WhHNNggutwVNrFnxnrU50B9QNmzt7cMPgH5mi0I18=";
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
    fontconfig
    freetype
    gtest
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  ### TODO: deepin-font-preview-plugin need dde-file-manger
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "ADD_SUBDIRECTORY(deepin-font-preview-plugin)" " " \
      --replace "/usr/share/deepin-manual/manual-assets/application/)" "$out/share/deepin-manual/manual-assets/application/)" \
      --replace "SET(CMAKE_INSTALL_PREFIX /usr)" "SET(CMAKE_INSTALL_PREFIX $out)"
  '';

  meta = with lib; {
    description = "Deepin Font Manager is used to install and uninstall font file for users with bulk install function";
    homepage = "https://github.com/linuxdeepin/deepin-font-manager";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
