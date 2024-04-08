{ lib, stdenvNoCC, fetchurl, unzip, installShellFiles, autoPatchelfHook, openssl }:

let
  pname = "databricks-cli";
  version = "0.216.0";

  url = "https://github.com/databricks/cli/releases/download/v${version}";

  sources = {
    x86_64-linux = fetchurl {
      url = "${url}/databricks_cli_${version}_linux_amd64.zip";
      sha256 = "sha256-wmytWJH+/+67t11j25JgkjMU5rp27HvNQuNEyp4jqWw=";
    };
    aarch64-linux = fetchurl {
     url = "${url}/databricks_cli_${version}_linux_arm64.zip";
     sha256 = "sha256-s2sD/LhQyOTQZ/IHvII6hURJ0pNfnHYusagVqqccOcA=";
    };

    x86_64-darwin = fetchurl {
      url = "${url}/databricks_cli_${version}_darwin_amd64.zip";
      sha256 = "sha256-0QNwvAAvzAjgQtvvLCSVrSTJulOMpDpezfEkbQhm/Kc=";
    };
    aarch64-darwin = fetchurl {
      url = "${url}/databricks_cli_${version}_darwin_arm64.zip";
      sha256 = "sha256-tr16U/6PJ3e4oief18NSLa43kgx3q5/SA2bZFa2TkQc=";
    };
  };

  src = sources.${stdenvNoCC.hostPlatform.system} or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation rec {
  inherit pname version src;

  name = pname;

  strictDeps = true;
  nativeBuildInputs = [ unzip installShellFiles ] ++ lib.optionals stdenvNoCC.isLinux [ autoPatchelfHook ];
  buildInputs = [ openssl ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    runHook preInstall

    install -Dm 755 ./databricks $out/bin/databricks

    runHook postInstall
  '';

  meta = with lib; {
    description = "A CLI client for Databricks";
    homepage = "https://github.com/databricks/cli";
    changelog = "https://github.com/databricks/cli/releases/tag/v${version}";
    license = "DB license";
    maintainers = [ "ahappypie" ];
    mainProgram = "databricks";
  };
}
