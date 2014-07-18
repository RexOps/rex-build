# vim: set syn=perl:

use Rex -feature => '0.42';
use Test::More;

do "auth.conf";

task test => group => test => sub {

  ok(1==1, "task is running");
  my $s = connection->server;
  ok($ENV{HTEST} =~ m/\Q$s\E/, "connected to $s");

  my $out = run "id";
  ok($out =~ /uid=0\(root\) gid=0\((root|wheel)\)/, "logged in as root");

  done_testing();
};
