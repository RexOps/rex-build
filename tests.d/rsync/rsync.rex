# vim: set syn=perl:
use Rex -feature => 0.42;
use Rex::Commands::Rsync;
use Test::More;
use Rex::Commands::Gather;

do "auth.conf";

timeout 15;

task "test", group => "test", sub {

   mkdir "/tmp/etc2", owner => "rsync_user";
   sync "files/etc/", "/tmp/etc2/";

   my %stat = stat "/tmp/etc2/my.cnf";

   ok($stat{uid} == 6000, "/tmp/etc2/my.cnf owner");
   ok($stat{gid} == 6000, "/tmp/etc2/my.cnf group");

   done_testing();
};

auth for => test => user => "rsync_user", password => "rsync.pw", sudo_password => "rsync.pw";
