{ config, lib, options, ... }: {
  options.slaanesh.caddy = {
    localAddressLSB = lib.mkOption {
      type = lib.types.ints.u8;
    };

    wildcardDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    virtualHosts = lib.mkOption {
      type = options.services.caddy.virtualHosts.type;
      default = { };
    };
  };

  config = {
    # https://doc.yunohost.org/fr/admin/get_started/providers/registrar/ovh/autodns/
    sops.secrets."ovh_dns" = { };

    containers.caddy = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      hostAddress6 = "fd00:100::1";
      localAddress = "192.168.100.${toString config.slaanesh.caddy.localAddressLSB}";
      localAddress6 = "fd00:100::${lib.toHexString config.slaanesh.caddy.localAddressLSB}";

      bindMounts = {
        freshrss = {
          hostPath = config.sops.secrets."ovh_dns".path;
          mountPoint = "/run/secrets/ovh_dns";
          isReadOnly = true;
        };
      };

      config = { lib, pkgs, ... }: {
        imports = [ ../../../modules/dns/resolved.nix ];

        services.caddy = {
          enable = true;
          package = pkgs.caddy.withPlugins {
            plugins = [ "github.com/caddy-dns/ovh@v1.1.0" ];
            hash = "sha256-q86gQb5S1bg383aqd1bQuuoURWHuz8E8IPP1s2LEXq8=";
          };
          email = "jonathan@tremesaygues.eu";
          environmentFile = "/run/secrets/ovh_dns";
          extraConfig = lib.concatMapStringsSep "\n" (domain: ''
            *.${domain} {
              abort
            }
          '') config.slaanesh.caddy.wildcardDomains;
          globalConfig = ''
            acme_dns ovh {
              endpoint ovh-eu
              application_key {$OVH_APPLICATION_KEY}
              application_secret {$OVH_APPLICATION_SECRET}
              consumer_key {$OVH_CONSUMER_KEY}
            }
          '';
          openFirewall = true;
          virtualHosts = config.slaanesh.caddy.virtualHosts;
        };

        networking = {
          useHostResolvConf = lib.mkForce false;
        };

        system.stateVersion = "26.11";
      };
    };

    networking = {
      firewall = {
        allowedTCPPorts = [
          80
          443
        ];
        allowedUDPPorts = [
          443
        ];
      };
      nat.forwardPorts = [
        {
          sourcePort = 80;
          proto = "tcp";
          destination = "${config.containers.caddy.localAddress}:${toString config.containers.caddy.config.services.caddy.httpPort}";
        }
        {
          sourcePort = 80;
          proto = "tcp";
          destination = "[${config.containers.caddy.localAddress6}]:${toString config.containers.caddy.config.services.caddy.httpPort}";
        }
        {
          sourcePort = 443;
          proto = "tcp";
          destination = "${config.containers.caddy.localAddress}:${toString config.containers.caddy.config.services.caddy.httpsPort}";
        }
        {
          sourcePort = 443;
          proto = "tcp";
          destination = "[${config.containers.caddy.localAddress6}]:${toString config.containers.caddy.config.services.caddy.httpsPort}";
        }
        {
          sourcePort = 443;
          proto = "udp";
          destination = "${config.containers.caddy.localAddress}:${toString config.containers.caddy.config.services.caddy.httpsPort}";
        }
        {
          sourcePort = 443;
          proto = "udp";
          destination = "[${config.containers.caddy.localAddress6}]:${toString config.containers.caddy.config.services.caddy.httpsPort}";
        }
      ];
    };
  };
}
