{ stdenv
, lib
, fetchFromGitHub
, buildGoModule
, pkg-config
, deepin-gettext-tools
, go-dbus-factory
, go-gir-generator
, go-lib
, gtk3
, glib
, libxcrypt
, gettext
, iniparser
, cracklib
, linux-pam
}:

buildGoModule rec {
  pname = "deepin-pw-check";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "e3c8d8ab32f3652356ce6fecfd07fbf611d6d869";
    sha256 = "sha256-d5jaGr8Mstey+Oe1S6cA6Q0cn2gHr7CJihMPYJc/bw4=";
  };

  vendorSha256 = "sha256-wRAY9mwZO/kkWPp1GTY7OyanVVwqsvpyzQJWXFrlV7U=";

  nativeBuildInputs = [
    pkg-config
    #gettext
    #deepin-gettext-tools
  ];

  buildInputs = [
    glib
    libxcrypt
    gtk3
    #iniparser
    #cracklib
    linux-pam
  ];

  postPatch = ''
    sed -i 's|iniparser/||' */*.c
    substituteInPlace misc/pkgconfig/libdeepin_pw_check.pc \
      --replace "/usr" "$out"
  '';

  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make install PREFIX="$out" PKG_FILE_DIR=$out/lib/pkg-config PAM_MODULE_DIR=$out/etc/pam.d
    # https://github.com/linuxdeepin/deepin-pw-check/blob/d5597482678a489077a506a87f06d2b6c4e7e4ed/debian/rules#L21
    ln -s $out/lib/libdeepin_pw_check.so $out/lib/libdeepin_pw_check.so.1
    runHook postInstall
  '';

  meta = with lib; {
    description = "a tool to verify the validity of the password";
    homepage = "https://github.com/linuxdeepin/deepin-pw-check";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
