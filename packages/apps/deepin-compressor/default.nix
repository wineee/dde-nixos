{ stdenv
, lib
, fetchFromGitHub
, dtkwidget
, qt5integration
, udisks2-qt5
, cmake
, qtbase
, qttools
, pkg-config
, kcodecs
, karchive
, wrapQtAppsHook
, minizip
, libzip
, libarchive
}:

stdenv.mkDerivation rec {
  pname = "deepin-compressor";
  version = "6.0.0.999";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "a0f988452490cc2770a4f376686f63a7c508ac23";
    sha256 = "sha256-I1TSx0SUK90UnXxmgLudh5Rf4wEjgFKfhfJ0irgZpA8=";
  };

  postPatch = ''
    substituteInPlace src/source/common/pluginmanager.cpp \
      --replace "/usr/lib/" "$out/lib/"
    substituteInPlace src/desktop/deepin-compressor.desktop \
      --replace "/usr" "$out"
  '';

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    qt5integration
    udisks2-qt5
    kcodecs
    karchive
    minizip
    libzip
    libarchive
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
    "-DUSE_TEST=OFF"
  ];

  preBuild = ''
    export PREFIX=${placeholder "out"}
  '';

  strictDeps = true;

  meta = with lib; {
    description = "A fast and lightweight application for creating and extracting archives";
    homepage = "https://github.com/linuxdeepin/deepin-compressor";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}