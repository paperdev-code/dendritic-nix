{
  stdenvNoCC,
  requireFile,
  unzip,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "berkeley-mono";
  version = "tx-02";

  nativeBuildInputs = [ unzip ];

  src = requireFile {
    name = "berkeley-mono.zip";
    url = "https://usgraphics.com/products/berkeley-mono";
    hash = "sha256-ybtupBjoayjXeR3QGN7NVIkpHvTVO4bx5WhgvXPxHJk=";
  };

  installPhase = ''
    mkdir -p "$out/share/fonts/opentype"
    unzip -j "$src" -d "$out/share/fonts/opentype" $(unzip -Z1 "$src" | grep -i '.otf$')
  '';
}
