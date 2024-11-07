{
  fusuma = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "185dfdni1gv139l02x7pjdi0p1x58izp93i2953s26z09x8s8xly";
      type = "gem";
    };
    version = "3.6.2";
  };
  fusuma-plugin-sendkey = {
    dependencies = ["fusuma" "revdev"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "136wi4mn6rh3zwpcafwbdmzrqlf39ird1n1y1lakq4irx6cnicpn";
      type = "gem";
    };
    version = "0.13.2";
  };
  revdev = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1b6zg6vqlaik13fqxxcxhd4qnkfgdjnl4wy3a1q67281bl0qpsz9";
      type = "gem";
    };
    version = "0.2.1";
  };
}
