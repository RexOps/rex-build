# vim: set syn=perl:
use Rex -feature => 0.42;
use Rex::Commands::Rsync;
use Test::More;
use Rex::Commands::Gather;

do "auth.conf";

timeout 15;

task "test", group => "test", sub {

   if(is_openwrt) {
      # strange failure on suse for update_package_db()
      ok(1==1, "no openwrt test");
      done_testing();
      return;
   }

   mkdir "/tmp/etc";
   sync "files/etc/", "/tmp/etc/";

   my %stat = stat "/tmp/etc/my.cnf";

   ok($stat{uid} == 6000, "/tmp/etc/my.cnf owner");
   ok($stat{gid} == 6000, "/tmp/etc/my.cnf group");

   done_testing();
};

auth for => test => user => "rsync.user", password => "rsync.pw", sudo_password => "rsync.pw";

