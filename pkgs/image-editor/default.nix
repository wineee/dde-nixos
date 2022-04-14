{ stdenv
, lib
, fetchFromGitHub
, dtkcore
, dtkgui
, dtkwidget
, dtkcommon
, cmake
, qttools
, pkgconfig
, wrapQtAppsHook
, opencv
, freeimage
}:

stdenv.mkDerivation rec {
  pname = "image-editor";
  version = "1.9.10";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-6NRjSkOOGIYghSoibf8moJKRMiepytHk+pn+zjD04mU=";
  };

  nativeBuildInputs = [ cmake pkgconfig qttools wrapQtAppsHook ];

  buildInputs = [
    dtkcommon
    dtkcore
    dtkgui
    dtkwidget
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
