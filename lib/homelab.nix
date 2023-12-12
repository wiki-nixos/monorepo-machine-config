{ lib
, self
, deploy-rs
, nixpkgs
, ...
}:
{
  /*
    Wrapper around pkgs.lib.nixosSystem that adds the common modules
  */
  mkSystem = { hostData, specialArgs, data-flake }:
    let
      inherit (hostData) hostName;
    in
    lib.nixosSystem rec {
      inherit (hostData) system;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          self.overlays.homelab
        ];
      };
      modules = [
        (./. + "/../nixosConfigurations/${hostName}/configuration") # every host has "configuration" directory. /. converts it to path
        { networking = { inherit hostName; }; }
        {
          imports = [
            ../nixosModules/common/dump.nix
            ../nixosModules/common/nix.nix
            ../nixosModules/common/time.nix
            ../nixosModules/common/packages.nix
            ../nixosModules/common/sshd.nix
            ../nixosModules/common/firewall.nix
            ../nixosModules/common/shell.nix

            data-flake.nixosModules.${hostName}

            specialArgs.selfModules.zsh
          ];
        }
      ]
        # TODO: add modules from the host config
      ;
      inherit specialArgs; # nixos-hardware is passed this way
    };
  /*
    Returns attrset in format expected by deploy-rs.

    Example:
    mkDeployRsNode {nodeName = "foo-node"; system = "x86_64-linux"; }: {
    profiles.system = {
      user = "root";
      path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.foo-node;
    };
    }
  */
  mkDeployRsNode = { nodeName, system }: {
    hostname = nodeName + ".mgmt.home.arpa"; # TODO: Make this more generic
    sshUser = "root";
    profiles.system = {
      user = "root";
      path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${nodeName};
    };
  };
}
