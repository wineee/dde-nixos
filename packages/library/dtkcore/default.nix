{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, pkg-config
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
    rev = "42bd299eb2137399ba3ed5248de95ca9870b5077";
    sha256 = "sha256-gqiQCAmT0a45WP2dwhoAEfmD72iMSip1UPIZVhGUIi4=";
  };

  patches = [
    (fetchpatch {
      name = "feat: Improve version information";
      url = "https://github.com/linuxdeepin/dtkcore/commit/c05c6a0a0f6a1e84307791a0605480cb65d02993.patch";
      sha256 = "sha256-YYtyXxVWSipL2KMjCwH0PZbte1Cj7wGMi+s2iu8VcS4=";
    })
  ];

  postPatch = ''
    substituteInPlace src/dsysinfo.cpp \
      --replace "/usr/share/deepin/distribution.info" "/etc/distribution.info" \
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
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
