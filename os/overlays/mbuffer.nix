self: super:
{
  mbuffer = super.mbuffer.overrideAttrs (oldAttrs: rec {
    version = "R20210829";

    src = super.fetchFromGitHub {
      owner = "aither64";
      repo = "mbuffer";
      rev = "f9eb8fd7a4535a3359c57d531a580cd4bfc2291b";
      sha256 = "sha256:1py5hvn83jirdif0gid9sfh5a0zgjf0w8nwi7nzzp6kq0r83m4vn";
    };

    nativeBuildInputs = [ super.which ];
  });
}
