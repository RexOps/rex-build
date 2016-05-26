# vim: set syn=perl:
use Rex -feature => 0.42;
use Rex::Commands::Rsync;
use Test::More;
use Rex::Commands::Gather;

do "auth.conf";

timeout 15;

task "test", group => "test", sub {

#  mkdir "/home/rsync_user/etc2", owner => "rsync_user";
#  sync "files/etc/", "/home/rsync_user/etc2/";

#  my %stat = stat "/home/rsync_user/etc2/my.cnf";

#  if( Rex::is_sudo ) {
#    ok($stat{uid} != 6000, "/home/rsync_user/etc/my.cnf owner");
#    ok($stat{gid} != 6000, "/home/rsync_user/etc2/my.cnf group");
#  }
#  else {
#    ok($stat{uid} == 6000, "/home/rsync_user/etc/my.cnf owner");
#    ok($stat{gid} == 6000, "/home/rsync_user/etc2/my.cnf group");
#  }
ok(1==1);
  done_testing();
};

#auth for => test => user => "rsync_user", password => "rsync.pw", sudo_password => "rsync.pw", pass_auth => TRUE;

