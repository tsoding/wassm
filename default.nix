with import <nixpkgs> {}; {
  websiteAsmEnv = stdenv.mkDerivation {
    name = "website-asm-env";
    buildInputs = [ stdenv gcc nasm gnumake ];
  };
}
