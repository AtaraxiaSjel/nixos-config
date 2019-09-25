{ pkgs, lib, config, ... }: {
  networking = {
    networkmanager.enable = false;
    wireless = {
      enable = config.deviceSpecific.isLaptop;
      # driver = "wext";
      networks.Alukard_5GHz = {
        pskRaw = "feee27000fb0d7118d498d4d867416d04d1d9a1a7b5dbdbd888060bbde816fe4";
        priority = 1;
      };
      networks.Alukard.pskRaw =
        "5ef5fe07c1f062e4653fce9fe138cc952c20e284ae1ca50babf9089b5cba3a5a";
      networks.SladkiySon.pskRaw =
        "86b1c8c60d3e99145bfe90e0af9bf552540d34606bb0d00b314f5b5960e46496";
      # interfaces = ["wlan0"];
      userControlled.enable = true;
    };
    firewall.enable = false;
    # usePredictableInterfaceNames = false;
    hostName = config.deviceSpecific.hostName;

    mullvad.enable = true;
  };
  # systemd.services.dhcpcd.serviceConfig.Type = lib.mkForce
  # "simple"; # TODO Make a PR with this change; forking is not acceptable for dhcpcd.
}
