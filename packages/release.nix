{ stdenvNoCC
, lib
, fetchFromGitHub
}:

stdenvNoCC.mkDerivation rec {
  pname = "release";
  version = "unstable-2022-08-11";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "193a3ace3c84b3f92ec9108030f944dcbc14d76a";
    sha256 = "";
  };

  meta = with lib; {
    description = "An easy to use calculator for ordinary users";
    homepage = "https://github.com/linuxdeepin/deepin-calculator";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
