{ lib
, stdenv
, runCommand
, glib
, gtk3
, gsettings-desktop-schemas
, dde-dock
, startdde
, dde-launcher
, dde-session-shell
, dde-session-ui
, dde-control-center
, deepin-movie-reborn
, dde-file-manager
, dde-grand-search
, deepin-screen-recorder
, deepin-system-monitor
, deepin-desktop-schemas
, extraGSettingsOverrides ? ""
, extraGSettingsOverridePackages ? [ ]
}:

let
  gsettingsOverridePackages = [
    dde-dock
    startdde
    dde-launcher
    dde-session-shell
    #deepin-movie-reborn
    dde-file-manager
    #dde-grand-search
    #deepin-system-monitor
    deepin-desktop-schemas
    gsettings-desktop-schemas
  ] ++ extraGSettingsOverridePackages;

in
with lib;

# TODO: Having https://github.com/NixOS/nixpkgs/issues/54150 would supersede this
runCommand "nixos-gsettings-desktop-schemas" { }
  ''
    schema_dir=$out/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas

    mkdir -p $schema_dir

    ${concatMapStrings (pkg: "cp -rvf ${glib.getSchemaPath pkg}/* $schema_dir\n") gsettingsOverridePackages}

    chmod -R a+w $out/share/gsettings-schemas/nixos-gsettings-overrides

    cat - > $schema_dir/nixos-defaults.gschema.override <<- EOF
    ${extraGSettingsOverrides}
    EOF

    ${glib.dev}/bin/glib-compile-schemas $schema_dir
  ''
