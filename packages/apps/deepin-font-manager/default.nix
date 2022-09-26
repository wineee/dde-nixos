{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtk
, qt5integration
, qt5platform-plugins
, dde-file-manager
, cmake
, qttools
, pkg-config
, wrapQtAppsHook
, fontconfig
, freetype
, gtest
, fileManagerPlugins ? true
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "deepin-font-manager";
  version = "5.9.13";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-eYx6biiK3ADNKel9cYqVH/P3sNPIzO1qKMeziBIu0Rg=";
  };

  patches = [
    (fetchpatch {
      name = "chore: use GNUInstallDirs in CmakeLists";
      url = "https://github.com/linuxdeepin/deepin-font-manager/commit/2aafa8e86a36ab5e39f42263556d832bbdeaedd6.patch";
      sha256 = "sha256-1cmrOeZu3Fof3HMuarc7BzN8BlfRRApcEfd8s9pC9Do=";
    })
  ];

  rmPluginPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "ADD_SUBDIRECTORY(deepin-font-preview-plugin)" " " 
  '';

  postPatch = lib.optionalString (!fileManagerPlugins) rmPluginPatch;

  nativeBuildInputs = [
    cmake
    pkg-config
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    fontconfig
    freetype
    gtest
    (lib.optional fileManagerPlugins dde-file-manager)
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  meta = with lib; {
    description = "Deepin Font Manager is used to install and uninstall font file for users with bulk install function";
    homepage = "https://github.com/linuxdeepin/deepin-font-manager";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
