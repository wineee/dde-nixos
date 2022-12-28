{ stdenvNoCC
, lib
, qt5integration
, qtbase
}:

stdenvNoCC.mkDerivation rec {
  pname = "qt5integration-style";
  version = qt5integration.version;
  src = qt5integration.out;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/${qtbase.qtPluginPrefix}
    ln -s $src/${qtbase.qtPluginPrefix}/styles  $out/${qtbase.qtPluginPrefix}/styles
  '';
  meta = qt5integration.meta // {
    description = "Qt style theme for qt5integration";
  };
}
