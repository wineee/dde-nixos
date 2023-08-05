{ stdenv
, lib
, fetchFromGitHub
, cmake
}:

let
  patchver = "16";
  
  opencv4 = fetchFromGitHub {
      owner = "opencv";
      repo = "opencv";
      rev = "4.6.0";
      hash = "sha256-zPkMc6xEDZU5TlBH3LAzvB17XgocSPeHVMG/U6kfpxg=";
  };

  patchSrc = fetchFromGitHub {
      owner = "nihui";
      repo = "opencv-mobile";
      rev = "v${patchver}";
      hash = "sha256-ijt3EoezUr9Pnh0FFHL7y1Or/ec63sgKds1p4Ob5Tcc=";
  };
in
stdenv.mkDerivation rec {
  pname = "opencv-mobile";
  version = "4.6-16";

  src = opencv4;

  nativeBuildInputs = [
    cmake
  ];

  outputs = [ "out" "dev" ];

  postPatch = ''
    patch -p1 -i ${patchSrc}/opencv-4.6.0-no-zlib.patch
    truncate -s 0 cmake/OpenCVFindLibsGrfmt.cmake
    rm -rf modules/gapi
    rm -rf modules/highgui
    cp -r ${patchSrc}/highgui modules/
    chmod +w modules/highgui
    patch -p1 -i ${patchSrc}/opencv-4.6.0-no-rtti.patch
  '';

  preConfigure = ''
    cmakeFlags="`cat ${patchSrc}/opencv4_cmake_options.txt` $cmakeFlags"
  '';

  cmakeFlags = [
    "-DBUILD_opencv_world=OFF"
  ];

  meta = with lib; {
    description = "The minimal opencv for Android, iOS, ARM Linux, Windows, Linux, MacOS, WebAssembly";
    homepage = "https://github.com/nihui/opencv-mobile";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ rewine ];
  };
} 
