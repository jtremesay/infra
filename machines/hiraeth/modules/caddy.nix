{
  config,
  lib,
  options,
  ...
}:
{
  options.slaanesh.caddy = {
    localAddress = lib.mkOption {
      type = lib.types.str;
    };
    localAddress6 = lib.mkOption {
      type = lib.types.str;
    };

    redirects = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Redirect mappings: hostname -> target_url";
    };

    reverseProxies = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Reverse proxy mappings: hostname -> backend_url";
    };

    virtualHosts = lib.mkOption {
      type = options.services.caddy.virtualHosts.type;
      default = { };
    };

    wildcardDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of wildcard domains for Caddy";
    };
  };

  config = {
    # https://doc.yunohost.org/fr/admin/get_started/providers/registrar/ovh/autodns/
    sops.secrets."ovh_dns" = {
      sopsFile = ../../../secrets/ovh_dns.yaml;
    };

    containers.caddy = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      hostAddress6 = "fd00:100::1";
      localAddress = config.slaanesh.caddy.localAddress;
      localAddress6 = config.slaanesh.caddy.localAddress6;

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
            dns ovh {
              endpoint ovh-eu
              application_key {$OVH_APPLICATION_KEY}
              application_secret {$OVH_APPLICATION_SECRET}
              consumer_key {$OVH_CONSUMER_KEY}
            }
            cert_issuer acme {
              dns
            }
            cert_issuer acme https://acme.zerossl.com/v2/DV90 {
              dns
            }
          '';
          openFirewall = true;
          virtualHosts =
            config.slaanesh.caddy.virtualHosts
            // (lib.mapAttrs (host: backend: {
              extraConfig = ''
                reverse_proxy ${backend}
              '';
            }) config.slaanesh.caddy.reverseProxies)
            // (lib.mapAttrs (host: target: {
              extraConfig = ''
                redir ${target}{uri} permanent
              '';
            }) config.slaanesh.caddy.redirects);
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
      nat.forwardPorts =
        map
          (
            forward:
            forward
            // {
              loopbackIPs = map (addr: addr.address) (
                if lib.hasPrefix "[" forward.destination then
                  config.networking.interfaces.eno1.ipv6.addresses
                else
                  config.networking.interfaces.eno1.ipv4.addresses
              );
            }
          )
          [
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
