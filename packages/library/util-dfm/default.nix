{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, cmake
, pkg-config
, wrapQtAppsHook
, qttools
, qtbase
, libmediainfo
, libsecret
, libisoburn
, libuuid
, udisks
}:

stdenv.mkDerivation rec {
  pname = "util-dfm";
  version = "2023-03-03";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "0e47c999c1fad4c11dcf4ac22ca71309a8376211";
    sha256 = "sha256-FvWtn18Gu+mvA+51W5t/aq3slEk+NyHoqE8eR9hAsRs=";
  };

  patches = [
    (fetchpatch {
      name = "chore: dont hardcode install path";
      url = "https://github.com/linuxdeepin/util-dfm/commit/4bd88a0f6e36b5aa5d176aa3a9f2c7ded1976620.patch";
      sha256 = "sha256-25pbXijM0ytXlk25B4WurN96MY3giLrlYu4FJRyW8/k=";
    })
    (fetchpatch {
      name = "fix: use pkgconfig to check mount";
      url = "https://github.com/linuxdeepin/util-dfm/commit/84844c805b48d1c241f7a6cab4f18d695eb22325.patch";
      sha256 = "sha256-zwZ/hmnbmFRPd1RT+ObB2iLM6hgaWNSwweUsnU2epD4=";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    libmediainfo
    libsecret
    libisoburn
    libuuid
    udisks
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DPROJECT_VERSION=${version}"
  ];

  preConfigure = ''
    # qt.qpa.plugin: Could not find the Qt platform plugin "minimal"
    # A workaround is to set QT_PLUGIN_PATH explicitly
    export QT_PLUGIN_PATH=${qtbase.bin}/${qtbase.qtPluginPrefix}
  '';

  meta = with lib; {
    description = "Gio wrapper for Qt applications";
    homepage = "https://github.com/linuxdeepin/gio-qt";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}