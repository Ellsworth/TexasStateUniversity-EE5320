{
  description = "Cross-toolchain zpu-elf built from zpugcc pinned commit";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation rec {
        pname = "zpu-elf-toolchain";
        version = "git-2025-11-05";

        src = pkgs.fetchFromGitHub {
          owner = "zylin";
          repo = "zpugcc";
          rev = "322875263beccb1d75936bd1dd9150c1647dc9c0";
          sha256 = "0bknwqba1sz0vvhq6hjpqh28i8r4a9g9kjiv721al68np4r1accp"; # you must compute accurate hash: run `nix-prefetch-url` or `nix-prefetch-git`
        };

nativeBuildInputs = [
  pkgs.gcc9 pkgs.binutils pkgs.bison pkgs.flex pkgs.texinfo
  pkgs.gmp pkgs.mpfr pkgs.libmpc pkgs.isl pkgs.gnumake
  pkgs.updateAutotoolsGnuConfigScriptsHook
];


        buildPhase = ''
          cd toolchain
          patchShebangs .
          chmod +x fixperm.sh build.sh || true
          ./fixperm.sh || true
          export CC="${pkgs.gcc9}/bin/gcc -fgnu89-inline"   # wrapped gcc
          export PREFIX="$PWD/install"
          . ./env.sh
          bash ./build.sh
        '';


        installPhase = ''
          mkdir -p $out
          cp -r install/* $out/
          chmod -R a+rx $out
        '';

        meta = with pkgs.lib; {
          description = "Cross GCC/newlib toolchain for ZPU (zpu-elf) from zpugcc pinned commit";
          homepage = "https://github.com/zylin/zpugcc";
          license = licenses.gpl2Plus;
          platforms = [ "x86_64-linux" ];
        };
      };
    };
}
