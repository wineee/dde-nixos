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
, ffmpegthumbnailer
, pcre
}:

stdenv.mkDerivation rec {
  pname = "image-editor";
  version = "1.0.21";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "3ced483348484b63350d4ee78ba7dd053c0c8cb6";
    sha256 = "sha256-EODxC2348H4jVTPHgbfVQm6bHMnNFL9u4l+pdWwNTvU=";
  };

  # patches = [
  #   (fetchpatch {
  #     name = "feat_check_PREFIX_value_before_set";
  #     url = "https://github.com/linuxdeepin/image-editor/commit/dae86e848cf53ba0ece879d81e8d5335d61a7473.patch";
  #     sha256 = "sha256-lxmR+nIrMWVyhl1jpA17x2yqJ40h5vnpqKKcjd8j9RY=";
  #   })
  #   (fetchpatch {
  #     name = "feat: use FULL install path";
  #     url = "https://github.com/linuxdeepin/image-editor/commit/855ae53a0444ac628aa0fe893932df6263b82e2e.patch";
  #     sha256 = "sha256-3Dynlwl/l/b6k6hOHjTdoDQ/VGBDfyRz9b8QY8FEsCc=";
  #   })
  # ];

  nativeBuildInputs = [ cmake pkgconfig qttools wrapQtAppsHook ];

  buildInputs = [
    dtk
    opencv
    freeimage
    libmediainfo
    ffmpegthumbnailer
    pcre
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
  ];

  meta = with lib; {
    description = "image editor lib for dtk";
    homepage = "https://github.com/linuxdeepin/image-editor";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
