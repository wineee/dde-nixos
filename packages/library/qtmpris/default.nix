{ stdenv
, lib
, fetchFromGitHub
, pkgconfig
, qmake
, qtdeclarative
, wrapQtAppsHook
}:

stdenv.mkDerivation rec {
  pname = "qtmpris";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "sailfishos";
    repo = pname;
    rev = version;
    sha256 = "sha256-kuM8hUdsa7N+eLDbwYw3ay+PWxg35zcTBOvGow1NlzI=";
  };

  postPatch = ''
    substituteInPlace declarative/declarative.pro \
      --replace '$$[QT_INSTALL_QML]' "$out/$qtQmlPrefix/"
      
    substituteInPlace src/src.pro \
      --replace '$$[QT_INSTALL_LIBS]' "$out/lib" \
      --replace '$$[QT_INSTALL_HEADERS]' "$out/include" \
      --replace '$$[QMAKE_MKSPECS]' "$out/mkspecs"
  '';

  nativeBuildInputs = [
    qmake
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [ qtdeclarative ];

  meta = with lib; {
    description = "Qt and QML MPRIS interface and adaptor";
    homepage = "https://github.com/sailfishos/qtmpris";
    license = licenses.lgpl2Plus;
    platforms = platforms.linux;
  };
} 
