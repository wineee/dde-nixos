{ stdenv
, lib
, fetchFromGitHub
, dtk
, cmake
, qttools
, pkgconfig
, wrapQtAppsHook
, opencv
, freeimage
}:

stdenv.mkDerivation rec {
  pname = "image-editor";
  version = "1.0.13";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-lqr70Vn1yO3Vvzib1HqCVNRDsD+SAfEKh5+ynQgzzlU=";
  };

  nativeBuildInputs = [ cmake pkgconfig qttools wrapQtAppsHook ];

  buildInputs = [
    dtk
    opencv
    freeimage
  ];

  postPatch = ''
    substituteInPlace libimageviewer/CMakeLists.txt \
      --replace "set(PREFIX /usr)" "set(PREFIX $out)"
    substituteInPlace libimagevisualresult/CMakeLists.txt \
      --replace "set(PREFIX /usr)" "set(PREFIX $out)"
  '';

  # fix bug https://github.com/linuxdeepin/developer-center/issues/2234
  postInstall = ''
    cp -r  $out/include/libimageviewer/* $out/include/
  '';

  meta = with lib; {
    description = "image editor lib for dtk";
    homepage = "https://github.com/linuxdeepin/image-editor";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
