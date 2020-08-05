{ pkgs, lib, config, ... }: {
  networking = {
    networkmanager.enable = false;
    wireless = {
      enable = config.deviceSpecific.isLaptop;
      networks.Alukard_5GHz = {
        pskRaw = "feee27000fb0d7118d498d4d867416d04d1d9a1a7b5dbdbd888060bbde816fe4";
        priority = 1;
      };
      networks.Alukard.pskRaw =
        "5ef5fe07c1f062e4653fce9fe138cc952c20e284ae1ca50babf9089b5cba3a5a";
      networks.AlukardAP = {
        pskRaw = "b8adc07cf1a9c7a7a5946c2645283b27ab91a8af4c065e5f9cde03ed1815811c";
        priority = 2;
      };
      networks.SladkiySon.pskRaw =
        "86b1c8c60d3e99145bfe90e0af9bf552540d34606bb0d00b314f5b5960e46496";
      networks.AlukardAP_5GHz = {
        pskRaw = "d1733d7648467a8a9cae9880ef10a2ca934498514b4da13b53f236d7c68b8317";
        priority = 1;
      };
      networks.POAS = {
        pskRaw = "6cfdb04f3e2d4279a4651608c9c73277708c67f7f1435b61228ecf00841e5155";
        priority = 3;
      };
      userControlled.enable = true;
    };
    firewall.enable = false;
    usePredictableInterfaceNames = true;
    hostName = config.device;
  };
}
