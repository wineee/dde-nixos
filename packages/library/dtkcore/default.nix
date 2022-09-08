{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, pkgconfig
, cmake
, gsettings-qt
, wrapQtAppsHook
, lshw
, dtkcommon
}:

stdenv.mkDerivation rec {
  pname = "dtkcore";
  version = "5.6.0.2";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "363b612ef790b707fd6e7b6bd9a7a41bd0c2a057";
    sha256 = "sha256-ygDn763aUMRFO/rzkwMb1K7hUUXrV5Y8N9SPrHoGjIU=";
  };

  postPatch = ''
    substituteInPlace src/dsysinfo.cpp \
      --replace "/usr/share/deepin/distribution.info" "/etc/distribution.info" \
  '';

  nativeBuildInputs = [
    cmake
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [
    gsettings-qt
    lshw
    dtkcommon
  ];

  cmakeFlags = [
    "-DBUILD_DOCS=OFF"
    "-DDSG_PREFIX_PATH='/run/current-system/sw'"
    "-DMKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs/modules"
  ];

  meta = with lib; {
    description = "Deepin tool kit core library";
    homepage = "https://github.com/linuxdeepin/dtkcore";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
