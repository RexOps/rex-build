# vim: set syn=perl:
use Rex -feature => 0.42;
use Rex::Commands::Rsync;
use Test::More;

do "auth.conf";

task "test", group => "test", sub {

   mkdir "/tmp/etc";
   sync "files/etc", "/tmp/etc";

   my %stat = stat "/tmp/etc/my.cnf";

   ok($stat{uid} == 6000, "/tmp/etc/my.cnf owner");
   ok($stat{gid} == 6000, "/tmp/etc/my.cnf group");

   done_testing();
};

auth for => test => user => "rsync.user", password => "rsync.pw";

