{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtkwidget
, qt5integration
, qt5platform-plugins
, cmake
, qttools
, pkg-config
, python3
, wrapQtAppsHook
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "deepin-ocr";
  version = "unstable-2022-11-10";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "1e55bf5b22a57be55aa8d583a81c75fe143a6f75";
    sha256 = "sha256-FO+wY8dwIaS+oxAUlipDAJEMBp1bwk4pnK2OlOhptYw=";
  };

  patches = [
    (fetchpatch {
      name = "fix_set_CMAKE_INSTALL_LIBDIR_as_lib";
      url = "https://github.com/linuxdeepin/deepin-ocr/commit/1b7477e062adaeea6871a17125677abf27edd371.patch";
      sha256 = "sha256-VQea6xFI4iaECSKVRICX6ZQ/glqN8Zr2S7c97TyfT68=";
    })
  ];

  postPatch = ''
    substituteInPlace src/CMakeLists.txt --replace "/usr" "$out"
    substituteInPlace com.deepin.Ocr.service \
      --replace "/usr/bin/deepin-ocr" "$out/bin/deepin-ocr"
    substituteInPlace deepin-ocr.desktop \
      --replace "/usr/bin/deepin-ocr" "$out/bin/deepin-ocr"
    substituteInPlace src/paddleocr-ncnn/details.cpp \
      --replace "/usr/share/deepin-ocr" "$out/share/deepin-ocr"
    substituteInPlace src/paddleocr-ncnn/paddleocr.cpp \
      --replace "/usr/share/deepin-ocr" "$out/share/deepin-ocr"
  '';

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    python3
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget 
    qt5integration
    qt5platform-plugins
  ];

  meta = with lib; {
    description = "Provides the base character recognition ability on deepin";
    homepage = "https://github.com/linuxdeepin/deepin-ocr";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
