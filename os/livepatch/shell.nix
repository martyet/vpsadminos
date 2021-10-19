let
  pkgs = import <nixpkgs> { overlays = [(import ../overlays/kernel.nix)]; };
  #stdenv = pkgs.ccacheStdenv;
  stdenv = pkgs.stdenv;
in with pkgs; stdenv.mkDerivation rec {
  kpatch-build = pkgs.stdenv.mkDerivation rec {
    name = "kpatch-build";
    src = fetchFromGitHub {
      owner = "dynup";
      repo = "kpatch";
      rev = "61fc3f10776017f21249e2cbd4b0639cbc325d9e";
      sha256 = "0x2rfmm6f171myshbj8rl8sgjpdh4qxml826kdgg46xln677jy6h";
    };
    postPatch = ''
      #patchShebangs scripts
    '';
    buildInputs = with pkgs; [
      gnumake
      elfutils
    ];
    buildPhase = ''
      make
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp kpatch-build/kpatch-{build,cc} $out/bin/
      cp kpatch-build/create-diff-object $out/bin/
      cp -r kmod $out/
    '';
    fixupPhase = ''
      patchShebangs $out/bin
    '';
  };
 # kktlinux = pkgs.kernel.overrideAttrs (oldAttrs: rec { postInstall = "mkdir -p $out/shit; cp -r . $out/shit/" + pkgs.kernel.postInstall; });
# kktlinux = pkgs.kernel.overrideAttrs (oldAttrs: rec { buildOut = true; });
  name = "kkt";
  buildInputs = with pkgs; [
    perl bc nettools openssl rsync gmp libmpc mpfr gawk zstd perl bison flex kernel.nativeBuildInputs
    git
    gnumake
    elfutils
    kpatch-build
    kernel
  #  kktlinux
  ];
  shellHook = ''
  ln -snf ${pkgs.kernel.buildOutput} ./kernel.buildOutput
  ln -snf ${pkgs.kernel.src} ./kernel.src
  ln -snf ${pkgs.kernel.dev} ./kernel.dev
  ln -snf ${pkgs.kernel} ./kernel

  mkdir -p ./kernel.build
  rsync -av --delete-after kernel.buildOutput/ ./kernel.build/
  chmod ug+w -R ./kernel.build
  cd ./kernel.build

  ln -snf ${pkgs.kernel.configfile.outPath} .config
  doshit() {
   sudo rm -Rf /home/base/.kpatch/
   kpatch-build -s . -c .config -j 40 ~/patch -v ~/tmp/os/os/livepatch/kernel.dev/vmlinux;
   cat /home/base/.kpatch/build.log
  }
  '';
}
