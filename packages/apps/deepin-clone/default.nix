{ stdenv
, lib
, fetchFromGitHub
, dtk
, qt5integration
, qt5platform-plugins
, dde-file-manager
, cmake
, qttools
, pkgconfig
, wrapQtAppsHook
}:

stdenv.mkDerivation rec {
  pname = "deepin-clone";
  version = "5.0.11";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-ZOJc8R82R9q87Qpf/J4CXE+xL6nvbsXRIs0boNY+2uk=";
  };

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    dde-file-manager
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  # qtWrapperArgs = [
  #   "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
  #   "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  # ];

  fixInstallPatch = ''
    #  substituteInPlace CMakeLists.txt \
    #    --replace "set(PREFIX /usr)" "set(PREFIX $out)"
  '';

  postPatch = fixInstallPatch;

  meta = with lib; {
    description = "Disk and partition backup/restore tool";
    homepage = "https://github.com/linuxdeepin/deepin-clone";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
