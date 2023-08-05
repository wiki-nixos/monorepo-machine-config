# [[file:../../new_project.org::*Adhoc WiFi][Adhoc WiFi:1]]
{ config, lib, infra, ... }:
{
  # Disable autogenerated names
  networking.usePredictableInterfaceNames = false;
  # Systemd-networkd enabled
  networking.useNetworkd = true;

  networking.wireless = {
    enable = true;
    networks = {
      "SomeFakeAccessPoint".psk = ""; };
    };
    systemd.network.networks = {
      "30-adhoc-wifi" = {
        enable = true;
        name = "wifi-lan";
        dns = [ "1.1.1.1" ];
        networkConfig = {
          # If needed, configure by hand
          # Address = [ ];
          # Gateway = 192.168.1.1
          DHCP = "yes";
          DNSSEC = "yes";
          DNSOverTLS = "no";
          # Disable ipv6 explicitly
          LinkLocalAddressing = "no";
        };
      };
    };
    # I am not using llmnr in my LAN
    services.resolved.llmnr = "false";

    # Any interface being up should be OK
    systemd.network.wait-online.anyInterface = true;
  }
# Adhoc WiFi:1 ends here
