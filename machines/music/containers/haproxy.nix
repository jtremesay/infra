{ config, ... }: {
  config = {
    containers.haproxy = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      hostAddress6 = "fd00:100::1";
      localAddress = "192.168.100.3";
      localAddress6 = "fd00:100::3";

      bindMounts = {
        certificates = {
          hostPath = "/var/lib/shared/acme";
          mountPoint = "/var/lib/acme/";
          isReadOnly = true;
        };
      };

      config = { lib, ... }: {
        imports = [ ../../../modules/dns/resolved.nix ];

        services.haproxy = {
          enable = true;
          config = ''
            global
              log stdout format raw local0
              maxconn 4096

            defaults
              log                  global
              mode                 http
              option               httplog
              option               dontlognull
              option               forwardfor
              option               http-server-close
              timeout connect      5s
              timeout client       30s
              timeout server       30s
              timeout http-request 10s
              timeout http-keep-alive 10s

            frontend http_in
              bind [::]:80 v4v6
              http-request redirect scheme https code 301

            frontend https_in
              # full.pem = clé privée + chaîne + certificat, dans cet ordre : exactement
              # ce que haproxy attend d'un seul fichier. C'est pour ça qu'il n'y a
              # qu'un seul chemin à surveiller et que ton watcher inotify est propre.
              bind [::]:443 v4v6 ssl crt /var/lib/acme/music.jtremesay.eu/full.pem alpn h2,http/1.1 strict-sni

              http-request set-header X-Forwarded-Proto https
              http-request set-header X-Real-IP          %[src]

              default_backend caddy

            backend caddy
              server web1 192.168.100.4:80
          '';
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

        system.stateVersion = "26.05";
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
          destination = "${config.containers.haproxy.localAddress}:80";
        }
        {
          sourcePort = 80;
          proto = "tcp";
          destination = "[${config.containers.haproxy.localAddress6}]:80";
        }
        {
          sourcePort = 443;
          proto = "tcp";
          destination = "${config.containers.haproxy.localAddress}:443";
        }
        {
          sourcePort = 443;
          proto = "tcp";
          destination = "[${config.containers.haproxy.localAddress6}]:443";
        }
      ];
    };
  };
}
