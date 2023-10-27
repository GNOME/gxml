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
        in with pkgs; rec {
          nativeBuildInputs = [ meson pkg-config ninja vala gobject-introspection ];
          buildInputs = [ libxml2 glib libgee ];
          propagatedBuildInputs = buildInputs;
        });
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          packages = packagesFor.${system};
        in {
          default = pkgs.stdenv.mkDerivation rec {
            name = "gxml";
            src = self;

            outputs = [ "out" "dev" "devdoc" ];

            PKG_CONFIG_GOBJECT_INTROSPECTION_1_0_GIRDIR = "${placeholder "dev"}/share/gir-1.0";
            PKG_CONFIG_GOBJECT_INTROSPECTION_1_0_TYPELIBDIR = "${placeholder "out"}/lib/girepository-1.0";

            doCheck = true;
            enableParallelBuilding = true;
            inherit (packages) nativeBuildInputs buildInputs propagatedBuildInputs;

            meta = with pkgs.lib; {
              description = "GXml provides a GObject API for manipulating XML and a Serializable framework from GObject to XML.";
              homepage = "https://gitlab.gnome.org/GNOME/gxml";
              license = licenses.lgpl21Plus;
              platforms = platforms.unix;
              maintainers = teams.gnome.members;
            };
          };
        });

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          packages = packagesFor.${system};
        in {
          default = pkgs.mkShell {
            packages = packages.nativeBuildInputs ++ packages.buildInputs;
          };
        });
    };
}
