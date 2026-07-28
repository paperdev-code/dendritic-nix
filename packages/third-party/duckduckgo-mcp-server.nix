{
  python3Packages,
  fetchFromGitHub,
}:
with python3Packages;
let
  pname = "duckduckgo-mcp-server";
  version = "0.6.1";
in
buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "nickclyde";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-X99edQE4317/WEadi/QQnLZHpWCMBW2ipa8am4lfO2Q=";
  };

  build-system = [
    hatchling
  ];

  propagatedBuildInputs = [
    beautifulsoup4
    httpx
    mcp
  ];

  pyproject = true;
}
