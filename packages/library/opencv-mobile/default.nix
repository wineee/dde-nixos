{ stdenv
, lib
, fetchFromGitHub
, pkg-config
, cmake
, qttools
, wrapQtAppsHook
, libisoburn
}:

stdenv.mkDerivation rec {
  pname = "opencv-mobile";
  version = "0.0.1.999";

  src = fetchFromGitHub {
    owner = "deepin";
    repo = pname;
    rev = "33c55b103f704fe329a1c93379bf99a6bddbb0f6";
    sha256 = "";
  };

  nativeBuildInputs = [
    cmake
    # qttools
    # pkg-config
    # wrapQtAppsHook
  ];

  #buildInputs = [ libisoburn ];
  postPatch = ''
    patch -p1 -i opencv-4.6.0-no-zlib.patch
    truncate -s 0 cmake/OpenCVFindLibsGrfmt.cmake
    rm -rf modules/gapi
    rm -rf modules/highgui
    cp -r ../highgui modules/
    patch -p1 -i ../opencv-4.6.0-no-rtti.patch
  '';

  cmakeFlags = [
    "`cat ${src}/opencv4_cmake_options.txt`"
  ];

  meta = with lib; {
    description = "The minimal opencv for Android, iOS, ARM Linux, Windows, Linux, MacOS, WebAssembly";
    homepage = "https://github.com/nihui/opencv-mobile";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ rewine ];
  };
} 
