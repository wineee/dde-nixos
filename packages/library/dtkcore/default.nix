{ stdenv
, lib
, fetchFromGitHub
, pkgconfig
, qmake
, gsettings-qt
, gtest
, wrapQtAppsHook
, lshw
, dtkcommon
}:

stdenv.mkDerivation rec {
  pname = "dtkcore";
  version = "5.5.33+";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "b2de0dd2e29057bca006a9c1f832ee230fb8bec8";
    sha256 = "sha256-V02KNmBZ7dIDyZci/NpsDQpQwTF4XoRyFvPtG+zYXsM=";
  };

  nativeBuildInputs = [
    qmake
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [
    gsettings-qt
    gtest
    lshw
    dtkcommon
  ];

  # DEFINES += PREFIX=\\\"$$INSTALL_PREFIX\\\"  path of dsg
  postPatch = ''
    substituteInPlace src/filesystem/filesystem.pri \
      --replace '$$INSTALL_PREFIX' "'/run/current-system/sw'"

    substituteInPlace src/dsysinfo.cpp \
      --replace "/usr/share/deepin/distribution.info" "/etc/distribution.info" \
      --replace 'lshw.start("lshw"' 'lshw.start("${lshw}/bin/lshw"'
  '';

  qmakeFlags = [
    "LIB_INSTALL_DIR=${placeholder "out"}/lib"
    "MKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs"
  ];

  meta = with lib; {
    description = "Deepin tool kit core library";
    homepage = "https://github.com/linuxdeepin/dtkcore";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
