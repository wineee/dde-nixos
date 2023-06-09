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
    rev = "ca4306c8733343d622dccbe7160dc178cfa30357";
    hash = "sha256-WPdSFsnFfwGrj9ErL0EKasmg6JfnWoxDosPoa21/+GM=";
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
    deepin-icon-theme
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
    maintainers = teams.deepin.members;
  };
}
