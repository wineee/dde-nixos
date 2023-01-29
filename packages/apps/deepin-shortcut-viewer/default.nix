{ stdenv
, lib
, fetchFromGitHub
, dtkwidget
, qt5integration
, qt5platform-plugins
, qmake
, qttools
, pkg-config
, wrapQtAppsHook
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "deepin-shortcut-viewer";
  version = "5.0.3";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-/VAT05ykFUCo4wBlylHbmgZ8Z9ptG2BCZo8ew3A4pkU=";
  };

  nativeBuildInputs = [
    qmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [ dtkwidget ];

  qmakeFlags = [
    "VERSION=${version}"
    "PREFIX=${placeholder "out"}"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/${qtbase.qtPluginPrefix}"
  ];

  postPatch = ''
    substituteInPlace view/shortcutscene.cpp \
      --replace "/usr/share/deepin-shortcut-viewer\n" "$out/share/deepin-shortcut-viewer\n"
  '';

  meta = with lib; {
    description = "Deepin Shortcut Viewer";
    homepage = "https://github.com/linuxdeepin/deepin-shortcut-viewer";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
