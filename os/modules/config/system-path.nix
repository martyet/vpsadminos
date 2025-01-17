{ config, lib, pkgs, ... }:

# based heavily on https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/config/system-path.nix

with lib;

let
  requiredPackages = with pkgs; [
    utillinux
    coreutils
    iproute
    iputils
    iptables
    mingetty
    procps
    bashInteractive
    runit
    shadow
    kmod
    zfstools
    xz
    gzip
    gnused
    gnugrep
    gnutar
    cpio
    curl
    diffutils
    findutils
    man
    netcat
    procps
    psmisc
    rsync
    time
    which
    gawk
    wget
    gnupg
    bzip2
    bridge-utils
    nettools
    bird
    bird6
    su
    lxcfs
    pciutils
    eudev
    rsyslog-light
  ];
in
{
  options = {
    environment = {
      systemPackages = mkOption {
        type = types.listOf types.package;
        default = [];
        example = literalExpression "[ pkgs.firefox pkgs.thunderbird ]";
      };
      pathsToLink = mkOption {
        type = types.listOf types.str;
        default = [];
        example = ["/"];
        description = "List of directories to be symlinked in <filename>/run/current-system/sw</filename>.";
      };
      extraOutputsToInstall = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "doc" "info" "docdev" ];
        description = "List of additional package outputs to be symlinked into <filename>/run/current-system/sw</filename>.";
      };
    };
    system.path = mkOption {
      internal = true;
    };
  };
  config = {
    environment.systemPackages = requiredPackages;
    environment.pathsToLink = [ "/bin" "/lib" "/man" "/share/man" ];
    system.path = pkgs.buildEnv {
      name = "system-path";
      paths = config.environment.systemPackages;
      inherit (config.environment) pathsToLink extraOutputsToInstall;
      postBuild = ''
        # TODO, any system level caches that need to regenerate
      '';
    };
  };
}
