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
  version = "5.6.0.2+";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "e221e232fc36be183c0f234f0b2113bf65baa080";
    sha256 = "sha256-brSluN0VKaI0U/D3B9dKNegiQQ8urfAvgp+RzV93rLM=";
  };

  patches = [
    (fetchpatch {
      name = "chore: use DSG_PREFIX_PATH set PREFIX";
      url = "https://github.com/linuxdeepin/dtkcore/commit/31f09e67b9d3c502b17247eadfdbd38bd32f97dd.patch";
      sha256 = "sha256-1MVBq0yoBgFrBy2Iuh4YA0S/1QfgQysFiaNia+bNTik=";
    })
  ];

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

  postPatch = ''
    substituteInPlace src/dsysinfo.cpp \
      --replace "/usr/share/deepin/distribution.info" "/etc/distribution.info" \
  '';

  cmakeFlags = [
    "-DBUILD_DOCS=OFF"
    "-DDSG_PREFIX_PATH='/run/current-system/sw'"
  ];

  meta = with lib; {
    description = "Deepin tool kit core library";
    homepage = "https://github.com/linuxdeepin/dtkcore";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
