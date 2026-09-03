{ config, pkgs, ... }:
{
  users.groups.deployrs = { };

  users.users.deployrs = {
    isNormalUser = true;
    group = config.users.groups.deployrs.name;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMGm5JRotZU5S8CIeY6UBRc6sVVw22lHHEHRHdwUXBJa jtremesay@nemo"
    ];
  };

  security.sudo.extraRules = [
    {
      groups = [ config.users.groups.deployrs.name ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
