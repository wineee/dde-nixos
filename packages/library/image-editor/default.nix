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
, pcre
}:

stdenv.mkDerivation rec {
  pname = "image-editor";
  version = "1.0.19";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-fAmpgR8ouW04iYLLBsu2n/T9Sy8Q5lSNSSW3HIvSw/Q=";
  };

  patches = [
    (fetchpatch {
      name = "feat_check_PREFIX_value_before_set";
      url = "https://github.com/linuxdeepin/image-editor/commit/a7c6655c57184952c10387771737f92b950246a5.patch";
      sha256 = "sha256-uGRKCkzZGFcwT0n9JFK3SuMWilaXDyqyAYh+VUdTo/w=";
    })
  ];

  postPatch = ''
    substituteInPlace libimageviewer/CMakeLists.txt \
      --replace "/usr" "$out"
  '';

  nativeBuildInputs = [ cmake pkgconfig qttools wrapQtAppsHook ];

  buildInputs = [
    dtk
    opencv
    freeimage
    libmediainfo
    pcre
  ];

  cmakeFlags = [ "-DCMAKE_INSTALL_LIBDIR=lib" ];

  meta = with lib; {
    description = "image editor lib for dtk";
    homepage = "https://github.com/linuxdeepin/image-editor";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
