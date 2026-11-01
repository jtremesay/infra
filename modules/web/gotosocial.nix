{ config, lib, ... }:
let
  cfg = config.slaanesh.gotosocial;
in
{
  options.slaanesh.gotosocial = {
    localAddress = lib.mkOption {
      type = lib.types.str;
      description = "Local IP address for the gotosocial container";
    };

    host = lib.mkOption {
      type = lib.types.str;
      description = "Hostname for the gotosocial service";
      default = "gotosocial.jtremesay.eu";
    };
  };

  config = {
    containers.gotosocial = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      localAddress = cfg.localAddress;

      config =
        { pkgs, lib, ... }:
        {
          imports = [ ../dns/resolved.nix ];

          services = {
            gotosocial = {
              enable = true;
              settings = {
                host = cfg.host;
                protocol = "https";
                bind-address = "0.0.0.0";
                port = 8080;
              };
            };
          };

          networking = {
            useHostResolvConf = lib.mkForce false;
            firewall.allowedTCPPorts = [
              8080
            ];
          };

          system.stateVersion = "26.05";
        };
    };

    slaanesh.caddy.reverseProxies."${cfg.host}" = "${config.containers.gotosocial.localAddress}:8080";

    services.borgmatic.settings.source_directories = [
      "/var/lib/nixos-containers/gotosocial/var/lib/gotosocial"
    ];
  };
}
