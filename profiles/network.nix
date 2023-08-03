{ pkgs, lib, config, ... }:
with config.deviceSpecific;
{
  networking = {
    networkmanager.enable = true;
    # wireless = {
    #   # enable = isLaptop;
    #   interfaces = lib.mkIf (config.device == "Dell-Laptop") [
    #     "wlo1"
    #   ];
    #   networks.Alukard_5GHz = {
    #     pskRaw = "feee27000fb0d7118d498d4d867416d04d1d9a1a7b5dbdbd888060bbde816fe4";
    #     priority = 1;
    #   };
    #   networks.Alukard.pskRaw =
    #     "5ef5fe07c1f062e4653fce9fe138cc952c20e284ae1ca50babf9089b5cba3a5a";
    #   networks.AlukardAP_5GHz = {
    #     pskRaw = "d1733d7648467a8a9cae9880ef10a2ca934498514b4da13b53f236d7c68b8317";
    #     priority = 1;
    #   };
    #   networks.AlukardAP.pskRaw = "b8adc07cf1a9c7a7a5946c2645283b27ab91a8af4c065e5f9cde03ed1815811c";
    #   };
    #   networks.SladkiySon.pskRaw =
    #     "86b1c8c60d3e99145bfe90e0af9bf552540d34606bb0d00b314f5b5960e46496";
    #   userControlled.enable = true;
    # };

    firewall = {
      enable = true;
      allowPing = true;
    };

    usePredictableInterfaceNames = true;
    hostName = config.device;
  };

  persist.state.directories = lib.mkIf config.networking.networkmanager.enable [
    "/etc/NetworkManager/system-connections"
  ];
}
