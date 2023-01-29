{ stdenv
, lib
, fetchFromGitHub
, getUsrPatchFrom
, dtkwidget
, qt5integration
, qt5platform-plugins
, dde-file-manager
, cmake
, libuuid
, partclone
, parted
, qttools
, pkg-config
, wrapQtAppsHook
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "deepin-clone";
  version = "5.0.11";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-ZOJc8R82R9q87Qpf/J4CXE+xL6nvbsXRIs0boNY+2uk=";
  };

  postPatch = getUsrPatchFrom {
    "app/${pname}-ionice" = [ ];
    "app/${pname}-pkexec" = [ ];
    "app/${pname}.desktop" = [ ];
    "app/com.deepin.pkexec.${pname}.policy.tmp" = [ ];
    "app/src/corelib/ddevicediskinfo.cpp" = [
      [ "/sbin/blkid" "${libuuid}/bin/blkid" ]
    ];
    "app/src/corelib/helper.cpp" = [
      [ "/bin/lsblk" "${libuuid}/bin/lsblk" ]
      [ "/sbin/sfdisk" "${libuuid}/bin/sfdisk" ]
      [ "/sbin/partprobe" "${parted}/bin/partprobe" ]
      [ "/usr/sbin" "${partclone}/bin" ]
    ];
  };

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    dde-file-manager
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
    "-DDISABLE_DFM_PLUGIN=YES"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/${qtbase.qtPluginPrefix}"
  ];

  postInstall = ''
    chmod +x $out/{bin,sbin}/${pname}-*
  '';

  meta = with lib; {
    description = "Disk and partition backup/restore tool";
    homepage = "https://github.com/linuxdeepin/deepin-clone";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
