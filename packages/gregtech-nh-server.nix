{
  fetchzip,
  jdk25_headless,
  lib,
  makeWrapper,
  runCommand,
  stdenvNoCC,
  extraConfigPatches ? [ ],
}:
let
  inherit (lib) concatStringsSep;

  pname = "gregtech-nh-server";
  version = "2.9.0";

  src = fetchzip {
    url = "https://downloads.gtnewhorizons.com/ServerPacks/GT_New_Horizons_${version}_Server_Java_17-26.zip";
    hash = "sha256-V3lydaIPUH7FifGSR+nNVAXwdmGi4T2mFrRwWfEBEcc=";
    stripRoot = false;
    postFetch = ''
      unzip -j $out/mods/industrialcraft-2-*.jar lib/EJML-core-0.26.jar -d $out/mods/ic2
      mkdir -p $out/mods/1.7.10
    '';
  };

  config = runCommand "gregtech-nh-config" { } ''
    cp -r --no-preserve=mode ${src}/config $out
    cd $out
    ${concatStringsSep "\n" extraConfigPatches}
  '';
in
stdenvNoCC.mkDerivation {
  inherit pname version;

  inherit src;
  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/lib
    ln -s $src/libraries $out/lib/libraries
    ln -s ${config} $out/lib/config
    ln -s $src/java9args.txt $out/lib/java9args.txt
    ln -s $src/mods $out/lib/mods
    ln -s $src/*.jar $out/lib
    makeWrapper ${jdk25_headless}/bin/java $out/bin/gregtech-nh-server \
      --append-flags "@$out/lib/java9args.txt -jar $out/lib/lwjgl3ify-forgePatches.jar nogui"
  '';

  meta = {
    description = "GregTech New Horizons Server";
    mainProgram = "gregtech-nh-server";
    licence = lib.licenses.cc-by-nc-sa-40;
  };
}
