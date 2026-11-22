{
  config,
  lib,
  options,
  ...
}:
{
  options.slaanesh.mirrors = {
    localAddress = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = {
    containers.mirrors = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      localAddress = config.slaanesh.mirrors.localAddress;

      config = { lib, ... }: {
        imports = [
          ../../../../modules/dns/resolved.nix
          ./archlinux.nix
        ];

        systemd.tmpfiles.rules = [
          "d /srv/http/mirrors 0755 root root -"
        ];

        services.caddy = {
          enable = true;
          openFirewall = true;

          virtualHosts."http://mirrors.jtremesay.eu".extraConfig = ''
            root * /srv/http/mirrors
            file_server browse
          '';
        };

        networking = {
          useHostResolvConf = lib.mkForce false;
        };

        system.stateVersion = "26.11";
      };
    };

    slaanesh.caddy.reverseProxies."mirrors.jtremesay.eu" =
      "${config.containers.mirrors.localAddress}:80";
  };
}
