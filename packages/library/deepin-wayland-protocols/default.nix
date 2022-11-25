{ stdenv
, lib
, fetchFromGitHub
, cmake
, extra-cmake-modules
}:
stdenv.mkDerivation rec {
  pname = "deepin-wayland-protocols";
  version = "1.6.0-deepin.1.1";

  src = fetchFromGitHub {
    owner = "justforlxz";
    repo = pname;
    rev = version;
    sha256 = "sha256-OW3Eiu0apa3sRrjet4bRUg6vsMycH6oejePZCxznH6Y=";
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
