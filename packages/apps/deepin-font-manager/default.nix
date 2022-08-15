{ stdenv
, lib
, fetchFromGitHub
, dtkcore
, dtkgui
, dtkwidget
, dtkcommon
, qt5integration
, qt5platform-plugins
, dde-file-manager
, cmake
, qttools
, pkgconfig
, wrapQtAppsHook
, fontconfig
, freetype
, gtest
, fileManagerPlugins ? false
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

  rmPluginPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "ADD_SUBDIRECTORY(deepin-font-preview-plugin)" " " 
  '';

  fixInstallPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "/usr/share/deepin-manual/manual-assets/application/)" "$out/share/deepin-manual/manual-assets/application/)" \
      --replace "SET(CMAKE_INSTALL_PREFIX /usr)" "SET(CMAKE_INSTALL_PREFIX $out)"
  '';

  postPatch = fixInstallPatch + lib.optionalString (!fileManagerPlugins) rmPluginPatch;

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
    (lib.optional fileManagerPlugins dde-file-manager)
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  # qtWrapperArgs = [
  #   "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
  #   "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  # ];

  meta = with lib; {
    description = "Deepin Font Manager is used to install and uninstall font file for users with bulk install function";
    homepage = "https://github.com/linuxdeepin/deepin-font-manager";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
