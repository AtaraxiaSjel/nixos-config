{
  lib,
  ...
}:
let
  inherit (lib) mkOption;
  inherit (lib.types) attrsOf listOf str;
in
{
  options.ataraxia.lists.sshHostKeys = mkOption {
    type = attrsOf (listOf str);
    default = { };
    description = ''
      SSH host public keys per host, used to generate programs.ssh.knownHosts entries.
      Attribute name is the knownHosts hostNames entry (e.g. "[static.ataraxiadev.com]:32323").
      Add keys of all your servers upfront, so pointing a domain to another
      server never requires a config change.
    '';
    example = {
      "[static.ataraxiadev.com]:32323" = [
        "ssh-ed25519 AAAA...server1..."
        "ssh-ed25519 AAAA...server2..."
      ];
    };
  };

  config = {
    ataraxia.lists.sshHostKeys = {
      "[static.ataraxiadev.com]:32323" = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqaegNloPun2yu8KTHHXF4fpG7q51ba3gKn1l0zk89u"
      ];
    };
  };
}
