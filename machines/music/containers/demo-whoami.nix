{
  config,
  lib,
  options,
  ...
}:
{
  options.slaanesh.demo-whoami = {
    localAddressLSB = lib.mkOption {
      type = lib.types.ints.u8;
    };
  };

  config = {
    containers.demo-whoami = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      localAddress = "192.168.100.${toString config.slaanesh.demo-whoami.localAddressLSB}";

      additionalCapabilities = [ "CAP_BPF" ];

      config = { lib, pkgs, ... }: {
        imports = [ ../../../modules/dns/resolved.nix ];

        virtualisation = {
          oci-containers.containers = {
            "demo-whoami" = {
              pull = "newer";
              image = "docker.io/traefik/whoami:latest";
              cmd = [ "--port=8080" ];
              ports = [ "8080:8080" ];
            };
          };
        };

        networking = {
          useHostResolvConf = lib.mkForce false;
        };

        system.stateVersion = "26.11";
      };
    };

    slaanesh.caddy.reverseProxies."music.jtremesay.eu" =
      "${config.containers.demo-whoami.localAddress}:8080";
  };
}
