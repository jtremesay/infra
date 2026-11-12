{ config, ... }: {
  config = {
    containers.caddy = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      hostAddress6 = "fd00:100::1";
      localAddress = "192.168.100.4";
      localAddress6 = "fd00:100::2";

      config = { lib, pkgs, ... }: {
        imports = [ ../../../modules/dns/resolved.nix ];

        services.caddy = {
          enable = true;
          package = pkgs.caddy.withPlugins {
            plugins = [ "github.com/caddy-dns/ovh@v1.1.0" ];
            hash = "sha256-q86gQb5S1bg383aqd1bQuuoURWHuz8E8IPP1s2LEXq8=";
          };

          virtualHosts = {
            "http://music.jtremesay.eu" = {
              extraConfig = ''
                respond "Hello from Caddy!"
              '';
            };

            "http://bla.music.jtremesay.eu" = {
              extraConfig = ''
                respond "bla from Caddy!"
              '';
            };

            "http://prout.music.jtremesay.eu" = {
              extraConfig = ''
                respond "prout from Caddy!"
              '';
            };
          };
        };

        networking = {
          useHostResolvConf = lib.mkForce false;
          firewall = {
            allowedTCPPorts = [
              80
              443
            ];
          };
        };

        system.stateVersion = "26.11";
      };
    };

    networking = {
      firewall.allowedTCPPorts = [
        80
        443
      ];

      nat.forwardPorts = [
        {
          sourcePort = 80;
          proto = "tcp";
          destination = "${config.containers.caddy.localAddress}:80";
        }
        {
          sourcePort = 80;
          proto = "tcp";
          destination = "[${config.containers.caddy.localAddress6}]:80";
        }
        {
          sourcePort = 443;
          proto = "tcp";
          destination = "${config.containers.caddy.localAddress}:443";
        }
        {
          sourcePort = 443;
          proto = "tcp";
          destination = "[${config.containers.caddy.localAddress6}]:443";
        }
      ];
    };
  };
}
