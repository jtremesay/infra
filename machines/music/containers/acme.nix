{ config, ... }: {
  config = {
    sops.secrets = {
      "ovh/music/acme" = { };
    };

    systemd.tmpfiles.rules = [
      "d ${config.containers.acme.bindMounts.certificates.hostPath} 0750 root root -"
    ];

    containers.acme = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      localAddress = "192.168.100.2";

      bindMounts = {
        ovh_acme = {
          hostPath = config.sops.secrets."ovh/music/acme".path;
          mountPoint = "/run/secrets/ovh_acme";
          isReadOnly = true;
        };

        certificates = {
          hostPath = "/var/lib/shared-acme";
          mountPoint = "/var/lib/acme/";
          isReadOnly = false;
        };
      };

      config = { lib, ... }: {
        imports = [ ../../../modules/dns/resolved.nix ];

        security.acme = {
          acceptTerms = true;
          defaults = {
            dnsProvider = "ovh";
            email = "jonathan@tremesaygues.eu";
            environmentFile = "/run/secrets/ovh_acme";
            server = "https://acme-staging-v02.api.letsencrypt.org/directory";
          };

          certs = {
            "music.jtremesay.eu" = {
              domain = "*.music.jtremesay.eu";
            };
          };
        };

        networking = {
          useHostResolvConf = lib.mkForce false;
        };

        system.stateVersion = "26.05";
      };
    };
  };
}
