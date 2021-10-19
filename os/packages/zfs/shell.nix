let
    pkgs = import <nixpkgs> {};
in pkgs.linuxPackages_5_4.zfs.overrideAttrs ( { buildInputs ? [], ... }: {
    buildInputs = buildInputs ++ (with pkgs; [
        shellcheck
        cppcheck
        checkbashisms
    ]);
})

