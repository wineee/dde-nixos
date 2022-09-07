{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, pkgconfig
, cmake
, qttools
, wrapQtAppsHook
, librsvg
, lxqt
, dtkcore
, dtkcommon
}:

stdenv.mkDerivation rec {
  pname = "dtkgui";
  version = "5.6.1.1+";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "09de488645171b9a55f27cf7a423c2012ed83e76";
    sha256 = "sha256-Q9qzxDulQ5W05TGxfwNzSTXqNRLMjcy0mojpBrCeYpo=";
  };

  patches = [
    (fetchpatch {
      name = "chore(mkspecs): define mkspecs self";
      url = "https://github.com/linuxdeepin/dtkgui/commit/092aa58ec96657d94ac5bf4724e3fcdd00e5f83d.patch";
      sha256 = "sha256-GoqRB1Iywq2ZdQWF011ArpUfXKGUUtJjrVTJ6sfPsJ0=";
    })
  ];

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkcore
    dtkcommon
    librsvg
    lxqt.libqtxdg
  ];

  cmakeFlags = [ 
    "-DBUILD_DOCS=OFF"
    "-DMKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs/modules"
  ];

  meta = with lib; {
    description = "Deepin Toolkit, gui module for DDE look and feel";
    homepage = "https://github.com/linuxdeepin/dtkgui";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
