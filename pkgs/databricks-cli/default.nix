{ lib, stdenvNoCC, fetchurl, unzip, installShellFiles, autoPatchelfHook, openssl }:

let
  pname = "databricks-cli";
  version = "0.217.0";

  url = "https://github.com/databricks/cli/releases/download/v${version}";

  sources = {
    x86_64-linux = fetchurl {
      url = "${url}/databricks_cli_${version}_linux_amd64.zip";
      sha256 = "sha256-yOQbmOHH9Fq6tTqAFQv1dwmc0yvhXRDDUF07JTFah7s=";
    };
    aarch64-linux = fetchurl {
     url = "${url}/databricks_cli_${version}_linux_arm64.zip";
     sha256 = "sha256-pIvl9CohC9khbejtQ346BjY8FpG4JF7o+e4yVbx8zvA=";
    };

    x86_64-darwin = fetchurl {
      url = "${url}/databricks_cli_${version}_darwin_amd64.zip";
      sha256 = "sha256-ooqQUyQgh1w3r2hTeinIZ0wG5xXt67e7R6nP9pvp5sI=";
    };
    aarch64-darwin = fetchurl {
      url = "${url}/databricks_cli_${version}_darwin_arm64.zip";
      sha256 = "sha256-GTKN45oB/PaOcuenhxc2Y8AsRCYGVcKT0nh6LJz3HZ4=";
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
