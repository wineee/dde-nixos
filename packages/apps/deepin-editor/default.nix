{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtk
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, cmake
, pkgconfig
, qttools
, wrapQtAppsHook
, kcodecs
, syntax-highlighting
, libchardet
, libuchardet
, libiconv
, gtest
}:

stdenv.mkDerivation rec {
  pname = "deepin-editor";
  version = "5.10.19";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-Be2cxJB9wIiuNP8TS43zhhdtOMa8lXAtbVtq9klrwAI=";
  };

  nativeBuildInputs = [
    cmake
    pkgconfig
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    kcodecs
    syntax-highlighting
    libchardet
    libuchardet
    libiconv
    gtest
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  patches = [
    (fetchpatch {
      url = "https://github.com/linuxdeepin/deepin-editor/commit/caa16d90dedf5106007d654897747f6f8f919439.patch";
      sha256 = "sha256-uUDNNvJ+JVTmbVLfdTeQ2PECbW/TbbgPWaBm0W57U60=";
      name = "do_not_include_com_deepin_dde_daemon_dock_h";
    })
  ];

  postPatch = ''
    substituteInPlace src/CMakeLists.txt \
      --replace "set(CMAKE_INSTALL_PREFIX /usr)" "set(CMAKE_INSTALL_PREFIX $out)" \
      --replace "/usr/share/deepin-manual/manual-assets/application/)" "$out/share/deepin-manual/manual-assets/application/)"
  '';

  meta = with lib; {
    description = "A desktop text editor that supports common text editing features";
    homepage = "https://github.com/linuxdeepin/deepin-editor";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
