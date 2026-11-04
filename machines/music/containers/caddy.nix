{ ... }: {
  config = {
    containers.caddy = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      hostAddress6 = "fd00:100::1";
      localAddress = "192.168.100.4";
      localAddress6 = "fd00:100::4";

      config = { lib, ... }: {
        imports = [ ../../../modules/dns/resolved.nix ];

        services.caddy = {
          enable = true;
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
            ];
          };
        };

        system.stateVersion = "26.05";
      };
    };
  };
}
