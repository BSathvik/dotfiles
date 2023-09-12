{
  description = "Kensho Deploy";

  inputs = {
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    # zentreefish.url = "github.kensho:kensho/zentreefish";
  };

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

    packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

  };
}
