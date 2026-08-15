{
  autoPatchelfHook,
  cargo-tauri,
  fetchFromGitHub,
  fetchPnpmDeps,
  glib,
  glib-networking,
  gtk3,
  librsvg,
  libayatana-appindicator,
  nodejs,
  openssl,
  pkg-config,
  pnpm,
  pnpmConfigHook,
  rustPlatform,
  webkitgtk_4_1,
  wrapGAppsHook3,
  ...
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "magneto";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "ingur";
    repo = "magneto";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ikIuSM4646gl1C8+3dPTKN6I5mH2S5Fkmvz4/ASymvg=";
  };

  cargoHash = "sha256-8Gqqeue3lNFDO2k5DhVYOkqkcfEPGnBUaTUvbkXxjyc=";

  pnpmRoot = "app";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-gAeuEDlqmTiQZubPSyjKVPwM9uuMNLwLUbziuXxai+Y=";
    sourceRoot = "${finalAttrs.src.name}/app";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    cargo-tauri.hook
    nodejs
    pkg-config
    pnpm
    pnpmConfigHook
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    glib-networking
    gtk3
    librsvg
    libayatana-appindicator
    openssl
    webkitgtk_4_1
  ];

  runtimeDependencies = [
    libayatana-appindicator
  ];

  patches = [ ./stage-daemon.patch ];

  cargoTestFlags = [
    "-p magneto-core"
    "-p magneto-cli"
    "-p magneto-daemon"
  ];
})
