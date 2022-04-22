{ stdenv
, lib
, fetchFromGitHub
, gettext
, python3Packages
, perlPackages
}:

stdenv.mkDerivation rec {
  pname = "deepin-gettext-tools";
  version = "unstable-2021-11-09";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "c913e2d7f9ea6ee394e3640dfca807d802806607";
    sha256 = "sha256-5Dd2QU6JYwuktusssNDfA7IHa6HbFcWo9sZf5PS7NtI=";
  };

  nativeBuildInputs = [ python3Packages.wrapPython ];

  buildInputs = [
    gettext
    perlPackages.perl
    perlPackages.ConfigTiny
    perlPackages.XMLLibXML
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  postPatch = ''
    sed -e 's/sudo cp/cp/' -i src/generate_mo.py
  '';

  postFixup = ''
    wrapPythonPrograms
    wrapPythonProgramsIn "$out/lib/${pname}"
    wrapProgram $out/bin/deepin-desktop-ts-convert --set PERL5LIB $PERL5LIB
  '';

  meta = with lib; {
    description = "Translation file processing utils for DDE development";
    homepage = "https://github.com/linuxdeepin/deepin-gettext-tools";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
