{ stdenv
, lib
, fetchFromGitHub
, cmake
, gtk3
, xcursorgen
, papirus-icon-theme
, breeze-icons
, hicolor-icon-theme
, deepin-icon-theme
}:

stdenv.mkDerivation rec {
  pname = "deepin-desktop-theme";
  version = "1.6.p6";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "f63dfe84fa8aff61b58ef6a8dae7f99a39ff74a4";
    sha256 = "sha256-r4rEvNq0MAKUhIW9HrtB2gsQNTjI3v3oCciAP+z62gQ=";
  };

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  nativeBuildInputs = [ 
    cmake
    gtk3
    xcursorgen
  ];

  propagatedBuildInputs = [
    breeze-icons
    papirus-icon-theme
    hicolor-icon-theme
  ];

  dontDropIconThemeCache = true;

  postFixup = ''
    rm -r $out/share/icons/flow
    for theme in $out/share/icons/*; do
      gtk-update-icon-cache $theme
    done
  '';

  meta = with lib; {
    description = "deepin desktop theme";
    homepage = "https://github.com/linuxdeepin/deepin-icon-theme";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
