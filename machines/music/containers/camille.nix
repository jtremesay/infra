{
  config,
  lib,
  options,
  ...
}:
{
  options.slaanesh.camille = {
    localAddressLSB = lib.mkOption {
      type = lib.types.ints.u8;
    };
  };

  config = {
    sops.secrets."camille" = {
      sopsFile = ../../../secrets/camille.music.yaml;
    };

    containers.camille = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      hostAddress6 = "fd00:100::1";
      localAddress = "192.168.100.${toString config.slaanesh.camille.localAddressLSB}";
      localAddress6 = "fd00:100::${lib.toHexString config.slaanesh.camille.localAddressLSB}";

      additionalCapabilities = [ "CAP_BPF" ];

      bindMounts = {
        secrets = {
          hostPath = config.sops.secrets."camille".path;
          mountPoint = "/run/secrets/camille";
          isReadOnly = true;
        };
      };

      config = { lib, pkgs, ... }: {
        imports = [ ../../../modules/dns/resolved.nix ];

        services.postgresql = {
          enable = true;
          package = pkgs.postgresql_18;
          ensureDatabases = [ "camille" ];
          ensureUsers = [
            {
              name = "camille";
              ensureDBOwnership = true;
            }
          ];
        };

        systemd.services.camille-postgresql-credentials = {
          description = "Generate and apply Camille PostgreSQL credentials";
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
              ${pkgs.postgresql_18}/bin/psql -X -v ON_ERROR_STOP=1 \
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
                ALLOWED_HOSTS = "camille.music.jtremesay.eu";
              };
              environmentFiles = [
                "/run/secrets/camille"
                "/var/lib/camille-db/oci.env"
              ];
            };

            # "camille-mattermost" = {
            #   pull = "newer";
            #   image = "docker.io/killruana/camille:main";
            #   cmd = [
            #     "camille"
            #     "mattermost"
            #   ];
            #   environment = {
            #     MATTERMOST_BASE_URL = "https://mattermost.jtremesay.eu";
            #     MATTERMOST_API_TOKEN_FILE = "/run/secrets/mattermost_api_token";
            #     ALLOWED_HOSTS = "camille.music.jtremesay.eu";
            #     DATABASE_URL = "postgresql://camille@localhost:5432/camille";
            #     SALT_KEY_FILE = "/run/secrets/salt_key";
            #     SECRET_KEY_FILE = "/run/secrets/secret_key";
            #   };
            # };
          };
        };

        networking = {
          useHostResolvConf = lib.mkForce false;
          firewall.allowedTCPPorts = [ 8000 ];
        };

        system.stateVersion = "26.11";
      };
    };

    slaanesh.caddy.reverseProxies."camille.music.jtremesay.eu" =
      "${config.containers.camille.localAddress}:8000";
  };
}
