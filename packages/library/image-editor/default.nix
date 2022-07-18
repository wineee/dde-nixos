{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtk
, cmake
, qttools
, pkgconfig
, wrapQtAppsHook
, opencv
, freeimage
, libmediainfo
}:

stdenv.mkDerivation rec {
  pname = "image-editor";
  version = "1.0.17";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-Oekryl18o1wzXI2OiRLvpcZfPMvoLqODCO1VU0mB8bA=";
  };

  nativeBuildInputs = [ cmake pkgconfig qttools wrapQtAppsHook ];

  buildInputs = [
    dtk
    opencv
    freeimage
    libmediainfo
  ];

  cmakeFlags = [ "-DCMAKE_INSTALL_LIBDIR=lib" ];

  patches = [
    (fetchpatch {
      name = "fix_use_correct_LIBDIR_for_pkgconfig";
      url = "https://github.com/linuxdeepin/image-editor/commit/8b2066ee16995442e1c4891c75f26d80bbb7a483.patch";
      sha256 = "sha256-548t4UjSx1AcKG1nBm6BSIlPASwyDZQ+Rp9H+dr7sOc=";
    })
    (fetchpatch {
      name = "feat_check_PREFIX_value_before_set";
      url = "https://github.com/linuxdeepin/image-editor/commit/a7c6655c57184952c10387771737f92b950246a5.patch";
      sha256 = "sha256-uGRKCkzZGFcwT0n9JFK3SuMWilaXDyqyAYh+VUdTo/w=";
    })
  ];

  meta = with lib; {
    description = "image editor lib for dtk";
    homepage = "https://github.com/linuxdeepin/image-editor";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
