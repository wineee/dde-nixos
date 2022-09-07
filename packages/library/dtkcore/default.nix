{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, pkgconfig
, cmake
, gsettings-qt
, wrapQtAppsHook
, pythonPackages
, lshw
, dtkcommon
}:

stdenv.mkDerivation rec {
  pname = "dtkcore";
  version = "5.6.0.2";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "e221e232fc36be183c0f234f0b2113bf65baa080";
    sha256 = "sha256-brSluN0VKaI0U/D3B9dKNegiQQ8urfAvgp+RzV93rLM=";
  };

  patches = [
    (fetchpatch {
      name = "chore: use DSG_PREFIX_PATH set PREFIX";
      url = "https://github.com/linuxdeepin/dtkcore/commit/31f09e67b9d3c502b17247eadfdbd38bd32f97dd.patch";
      sha256 = "sha256-1MVBq0yoBgFrBy2Iuh4YA0S/1QfgQysFiaNia+bNTik=";
    })
    (fetchpatch {
      name = "chore(mkspecs): define mkspecs self";
      url = "https://github.com/linuxdeepin/dtkcore/commit/836eb1ebdb38d76a4f3883370a551b89f85e4982.patch";
      sha256 = "sha256-THvv3tezmvw+g5qNIzu+1Ah0ZUz815vRJHMoU7Py8Fg=";
    })
    (fetchpatch {
      name = "add EXECUTE PERMISSION for python script";
      url = "https://github.com/linuxdeepin/dtkcore/commit/cb520dd6c212206ec57dbc3d89c9654535b8fca2.patch";
      sha256 = "sha256-woR8Xa+syhk5C7s1C1tV3MVFLdqcEFpbvajTF3WjyxM=";
    })
  ];

  postPatch = ''
    substituteInPlace src/dsysinfo.cpp \
      --replace "/usr/share/deepin/distribution.info" "/etc/distribution.info" \
  '';

  nativeBuildInputs = [
    cmake
    pkgconfig
    wrapQtAppsHook
    pythonPackages.wrapPython
  ];

  buildInputs = [
    gsettings-qt
    lshw
    dtkcommon
  ];

  cmakeFlags = [
    "-DBUILD_DOCS=OFF"
    "-DDSG_PREFIX_PATH='/run/current-system/sw'"
    "-DMKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs/modules"
  ];

  postFixup = ''
    wrapPythonProgramsIn "$out/lib/libdtk-${version}/DCore/bin" "$out $pythonPath"
  '';

  meta = with lib; {
    description = "Deepin tool kit core library";
    homepage = "https://github.com/linuxdeepin/dtkcore";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
