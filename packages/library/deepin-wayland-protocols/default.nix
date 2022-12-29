{ stdenv
, lib
, fetchFromGitHub
, cmake
, extra-cmake-modules
}:
stdenv.mkDerivation rec {
  pname = "deepin-wayland-protocols";
  version = "1.6.0-deepin.1.2";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "193899bc0a8a9a726d01bbc96d42d5c4664cfb0a";
    sha256 = "sha256-8Im3CueC8sYA5mwRU/Z7z8HA4mPQvVSqcTD813QCYxo=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  meta = with lib; {
    description = "Xml files of the non-standard wayland protocols use in deepin";
    homepage = "https://github.com/linuxdeepin/deepin-wayland-protocols";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
  };
}
