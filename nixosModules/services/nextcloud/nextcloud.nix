{
  config,
  pkgs,
  lib,
  localLib,
  ...
}:
let
  inherit (lib.homelab) getServiceConfig getServiceFqdn getSrvSecret;

  srvName = "nextcloud";

  luks = {
    device_name = "luks_nextcloud";
    UUID = "0523d6c9-9ea5-4296-85a2-5655189fd0b5";
  };
in
{
  # Service configuration
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud27;
    hostName = getServiceFqdn srvName;

    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      # Predicated on postgres running on the same host
      dbhost = getServiceFqdn "db";
      dbname = "nextcloud";
      dbpassFile = config.age.secrets.dbpassFile.path;
      adminuser = "root";
      overwriteProtocol = "https";
      adminpassFile = config.age.secrets.adminpassFile.path;
    };
    extraOptions = getServiceConfig srvName;

    secretFile = config.age.secrets.nextcloudSecrets.path;
  };

  # Secrets
  age.secrets =
    let
      nextcloudUsr = config.systemd.services.nextcloud-setup.serviceConfig.User;
    in
    {
      dbpassFile = {
        file = getSrvSecret srvName "dbpassFile";
        owner = nextcloudUsr;
        group = nextcloudUsr;
      };
      adminpassFile = {
        file = getSrvSecret srvName "adminpassFile";
        owner = nextcloudUsr;
        group = nextcloudUsr;
      };
      nextcloudSecrets = {
        file = getSrvSecret srvName "nextcloudSecrets";
        owner = nextcloudUsr;
        group = nextcloudUsr;
      };
    };

  # LUKS setup
  systemd.services.nextcloud-setup.unitConfig.RequiresMountsFor = [ config.services.nextcloud.home ];

  environment.etc."crypttab".text = localLib.mkCryptTab { inherit (luks) device_name UUID; };
  systemd.mounts = [
    (localLib.mkLuksMount {
      inherit (luks) device_name;
      target = config.services.nextcloud.home;
    })
  ];
}
