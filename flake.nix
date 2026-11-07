{
  description = "8track";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        asdf-system = pkgs.sbcl.buildASDFSystem {
          pname = "8track";
          version = "0.1.0";

          src = self;

          systems = ["8track"];

          lispLibs = with pkgs.sbcl.pkgs; [
            dexador
            plump
            lquery
            lparallel
            serapeum
            quri
            local-time
          ];
        };

        sbcl-with-eighttrack = (pkgs.sbcl.withOverrides (self: super: {"8track" = asdf-system;}))
            .withPackages (ps: [
          ps."8track"
        ]);
      in {
        devShells.default = let
          libs = with pkgs; [openssl];
        in
          pkgs.mkShell {
            packages = with pkgs; [
              openssl
            ];

            shellHook = ''
              export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath libs}:$LD_LIBRARY_PATH
            '';
          };

        packages.eighttrack = pkgs.stdenv.mkDerivation {
          name = "8track";
          version = "0.1.0";
          src = self;

          nativeBuildInputs = [sbcl-with-eighttrack];
          buildInputs = with pkgs; [
            openssl
          ];

          buildPhase = ''
            runHook preBuild
            sbcl \
              --eval '(load (sb-ext:posix-getenv "ASDF"))' \
              --eval '(asdf:load-system :8track)' \
              --eval "(sb-ext:save-lisp-and-die \"8track\"
                       :executable t
                       :toplevel #'dev.shft.8track:main)"
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            install -Dm755 8track $out/bin/8track
            runHook postInstall
          '';

          dontStrip = true;
        };

        packages.default = self.packages.${system}.eighttrack;

        apps = rec {
          eighttrack = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "8track-run" ''
              ${self.packages.${system}.eighttrack}/bin/8track
            '';
          };

          default = eighttrack;
        };
      }
    );
}
