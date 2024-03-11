{ lib, stdenvNoCC, fetchurl, unzip, installShellFiles, autoPatchelfHook, openssl }:

let
  pname = "databricks-cli";
  version = "0.215.0";

  url = "https://github.com/databricks/cli/releases/download/v${version}";

  sources = {
    x86_64-linux = fetchurl {
      url = "${url}/databricks_cli_${version}_linux_amd64.zip";
      sha256 = "sha256-0LH05DMm2DejUzxHWPVFrEE1yc1+ogA2Iug1q8LG22Y=";
    };
    aarch64-linux = fetchurl {
     url = "${url}/databricks_cli_${version}_linux_arm64.zip";
     sha256 = "sha256-fYmFSDY+RHXGA2Q6airP7Xo4nOOYIUlecbrw3ocrOJA=";
    };

    x86_64-darwin = fetchurl {
      url = "${url}/databricks_cli_${version}_darwin_amd64.zip";
      sha256 = "sha256-JW/Tgur0cPKrAPbJdeonKdMSkcwVHZvneA/gLsG65mk=";
    };
    aarch64-darwin = fetchurl {
      url = "${url}/databricks_cli_${version}_darwin_arm64.zip";
      sha256 = "sha256-Sfxi3F/blbKsuWsqlJtpF6GgZQZgByZ5ratvmRgLo9E=";
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
