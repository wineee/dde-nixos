{ stdenv
, lib
, getUsrPatchFrom
, fetchFromGitHub
, dtk
, qt5integration
, qt5platform-plugins
, qmake
, qttools
, pkg-config
, qtwebengine
, wrapQtAppsHook
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "dmarked";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    fetchSubmodules = true;
    rev = "d3eb1ed77a0b1f8af0a7f2ce4c24226925755592";
    sha256 = "sha256-d3oTzNC/h4RZqu7Q7PTCtop79+EHeypp8vYenJL9YcE=";
  };

  postPatch = getUsrPatchFrom {
    "${pname}.desktop" = [ ];
  };

  nativeBuildInputs = [
    qmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    qtwebengine
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  qmakeFlags = [
    "PREFIX=${placeholder "out"}"
    "LIBS_PREFIX=${placeholder "out"}"
  ];

  meta = with lib; {
    description = "dtk based markdown editor";
    homepage = "https://github.com/DMarked/DMarked";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
