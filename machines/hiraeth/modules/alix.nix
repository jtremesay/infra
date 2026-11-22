{
  config,
  lib,
  ...
}:
{
  options.slaanesh.alix = {
    localAddress = lib.mkOption {
      type = lib.types.str;
    };
    localAddress6 = lib.mkOption {
      type = lib.types.str;
    };

    sshPort = lib.mkOption {
      type = lib.types.port;
    };
  };

  config = {
    sops.secrets."alix" = {
      sopsFile = ../secrets/alix.yaml;
    };

    containers.alix = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      hostAddress6 = "fd00:100::1";
      localAddress = config.slaanesh.alix.localAddress;
      localAddress6 = config.slaanesh.alix.localAddress6;

      additionalCapabilities = [ "CAP_BPF" ];

      bindMounts = {
        secrets = {
          hostPath = config.sops.secrets."alix".path;
          mountPoint = "/run/secrets/alix";
          isReadOnly = true;
        };
      };

      config = { lib, pkgs, ... }: {
        imports = [ ../../../modules/dns/resolved.nix ];

        services = {
          postgresql = {
            enable = true;
            package = pkgs.postgresql_19;
            ensureDatabases = [ "camille" ];
            ensureUsers = [
              {
                name = "camille";
                ensureDBOwnership = true;
              }
            ];
          };

          openssh.enable = true;
        };

        users = {
          users.ci = {
            isSystemUser = true;
            group = "ci";
            shell = pkgs.bash;
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPeqo1u6qpMDrpAc8fu0iVSGqVDNxzXM2qXRa/dBJ+2C jtremesay@nemo"
            ];
          };
          groups.ci = { };
        };

        security.sudo.extraRules = [
          {
            users = [ "ci" ];
            commands = [
              {
                command = "/run/current-system/sw/bin/systemctl restart podman-camille-web.service podman-camille-mattermost.service";
                options = [ "NOPASSWD" ];
              }
            ];
          }
        ];

        systemd.services.camille-postgresql-credentials = {
          description = "Generate and apply camille PostgreSQL credentials";
          requires = [ "postgresql-setup.service" ];
          after = [ "postgresql-setup.service" ];
          serviceConfig = {
            Type = "oneshot";
            User = "postgres";
            Group = "postgres";
            StateDirectory = "camille-db";
            StateDirectoryMode = "0700";
            UMask = "0077";
          };
          script = ''
            passwordFile=/var/lib/camille-db/password
            environmentFile=/var/lib/camille-db/oci.env

            if [ ! -s "$passwordFile" ]; then
              ${pkgs.openssl}/bin/openssl rand -hex 32 > "$passwordFile"
              chmod 0600 "$passwordFile"
            fi

            password="$(< "$passwordFile")"
            printf '%s\n%s\n' "$password" "$password" |
              ${pkgs.postgresql_19}/bin/psql -X -v ON_ERROR_STOP=1 \
                -d postgres --command='\password camille'

            printf 'DATABASE_URL=postgresql://camille:%s@localhost:5432/camille\n' \
              "$password" > "$environmentFile"
            chmod 0600 "$environmentFile"
          '';
        };

        systemd.services.podman-camille-web = {
          requires = [ "camille-postgresql-credentials.service" ];
          after = [ "camille-postgresql-credentials.service" ];
        };

        virtualisation = {
          oci-containers.containers = {
            "camille-web" = {
              pull = "newer";
              image = "docker.io/killruana/camille:v6";
              extraOptions = [ "--network=host" ];
              environment = {
                MATTERMOST_BASE_URL = "https://mattermost.jtremesay.eu";
                ALLOWED_HOSTS = "alix.jtremesay.eu";
              };
              environmentFiles = [
                "/run/secrets/alix"
                "/var/lib/camille-db/oci.env"
              ];
            };

            "camille-mattermost" = {
              pull = "newer";
              image = "docker.io/killruana/camille:v6";
              cmd = [
                "camille"
                "mattermost"
              ];
              extraOptions = [ "--network=host" ];
              environment = {
                MATTERMOST_BASE_URL = "https://mattermost.jtremesay.eu";
                ALLOWED_HOSTS = "alix.jtremesay.eu";
              };
              environmentFiles = [
                "/run/secrets/alix"
                "/var/lib/camille-db/oci.env"
              ];
            };
          };
        };

        networking = {
          useHostResolvConf = lib.mkForce false;
          firewall.allowedTCPPorts = [ 8000 ];
        };

        system.stateVersion = "26.11";
      };
    };

    slaanesh.caddy.reverseProxies."alix.jtremesay.eu" = "${config.containers.alix.localAddress}:8000";

    networking = {
      firewall.allowedTCPPorts = [ config.slaanesh.alix.sshPort ];

      nat.forwardPorts = [
        {
          sourcePort = config.slaanesh.alix.sshPort;
          proto = "tcp";
          destination = "${config.containers.alix.localAddress}:22";
        }
        {
          sourcePort = config.slaanesh.alix.sshPort;
          proto = "tcp";
          destination = "[${config.containers.alix.localAddress6}]:22";
        }
      ];
    };
  };
}
