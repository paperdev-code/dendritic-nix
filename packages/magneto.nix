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
  writeText,
}:
let
  stageDaemonPatch = writeText "stage-daemon.patch" ''
    diff --git a/app/scripts/stage-daemon.mjs b/app/scripts/stage-daemon.mjs
    index ac02281..c4ed9f0 100644
    --- a/app/scripts/stage-daemon.mjs
    +++ b/app/scripts/stage-daemon.mjs
    @@ -28,7 +28,7 @@ const buildArgs = ["build", "-p", "magneto-daemon"];
     if (release) buildArgs.push("--release");
     execFileSync("cargo", buildArgs, { stdio: "inherit", cwd: workspaceRoot });
     
    -const src = join(workspaceRoot, "target", profile, exeName);
    +const src = join(workspaceRoot, "target", triple, profile, exeName);
     const destDir = join(appDir, "src-tauri", "binaries");
     mkdirSync(destDir, { recursive: true });
     const dest = join(destDir, isWindows ? `magneto-daemon-$'{triple}.exe` : `magneto-daemon-$'{triple}`);
  '';
in
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
    hash = "sha256-SfJ6wNEZj6+N9nVzOJ6smbdH1/rClJOpZqmDEnB95eQ=";
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

  patches = [ stageDaemonPatch ];

  cargoTestFlags = [
    "-p magneto-core"
    "-p magneto-cli"
    "-p magneto-daemon"
  ];
})
