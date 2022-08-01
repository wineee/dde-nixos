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
  version = "1.0.18+";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "c06fb00a6ac8a6c27a062fa2e7a5756c69e707b7";
    sha256 = "sha256-/YGlZ0GWYQLmLRqy3lUNkG7z1vkmj6ywj8BJJga1Hqs=";
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
