{
  home-manager.users.alukard = {
    programs.git = {
      enable = true;
      userEmail = "alukard.develop@gmail.com";
      userName = "Dmitriy Kholkin";
      signing = {
        signByDefault = true;
        key = "922DA6E758A0FE4CFAB4E4B2FD266B810DF48DF2";
      };
      extraConfig = {
        core = {
          editor = "code --wait";
        };
      };
    };
  };
}