{ config, ... }:
let
  srvName = "home-assistant";
  inherit (config) my-data;
in
# srvConfig = my-data.lib.getServiceConfig srvName;
{
  age.secrets.zwaveSecrets = {
    file = my-data.lib.getSrvSecret srvName "zwave-secrets";
    mode = "444";
    # owner = head (split ":" config.systemd.services.zwave-js.serviceConfig.User); # User is 'zwave-js:0'
    # owner = config.systemd.services.zwave-js.serviceConfig.User; # User is 'zwave-js:0'
    # group = config.systemd.services.zwave-js.serviceConfig.User; # User is 'zwave-js:0'
  };

  services.zwave-js = {
    enable = true;
    serialPort = "/dev/ttyUSB0";
    secretsConfigFile = config.age.secrets.zwaveSecrets.path;
  };
  # /* Sets up the rules for the USB dongle */
  # services.udev.extraRules = ''
  #   KERNEL=="ttyUSB[0-9]*",MODE="0666"
  # '';
}
