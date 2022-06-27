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
  version = "5.10.23";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-6K9yQhYQrbqdb5HQeszdvYPi00PMndEaaMOza5griFQ=";
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
      name = "do_not_include_com_deepin_dde_daemon_dock_h";
      url = "https://github.com/linuxdeepin/deepin-editor/commit/caa16d90dedf5106007d654897747f6f8f919439.patch";
      sha256 = "sha256-uUDNNvJ+JVTmbVLfdTeQ2PECbW/TbbgPWaBm0W57U60=";
    })
    (fetchpatch {
      name = "fix_broken_KF5_include_path";
      url = "https://github.com/linuxdeepin/deepin-editor/commit/c4b2e93f7cf0146833d2b78b516dc25f3976763f.patch";
      sha256 = "sha256-oATccrlQBcyL6nz3ioY/9XEuHXdMqZfegFXGSowQINs=";
    })
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "add_subdirectory(tests)" ""
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
