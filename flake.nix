{
  description = "GXml provides a GObject API for manipulating XML and a Serializable framework from GObject to XML.";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [
        "aarch64-linux"
        "i686-linux"
        "riscv64-linux"
        "x86_64-linux"
        "x86_64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

      packagesFor = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in with pkgs; {
          nativeBuildInputs = [ meson pkg-config ninja vala ];
          buildInputs = [ libxml2 glib libgee ];
        });
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          systemPackages = packagesFor.${system};
        in {
          default = pkgs.stdenv.mkDerivation rec {
            name = "gxml";
            src = self;

            outputs = [ "out" "dev" "devdoc" ];

            enableParallelBuilding = true;
            inherit (systemPackages) nativeBuildInputs buildInputs;
          };
        });

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          systemPackages = packagesFor.${system};
        in {
          default = pkgs.mkShell {
            packages = systemPackages.nativeBuildInputs ++ systemPackages.buildInputs;
          };
        });
    };
}
