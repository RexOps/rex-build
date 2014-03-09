# vim: set syn=perl:

use Rex -feature => '0.42';
use Test::More;

do "auth.conf";

task "test", group => "test", sub {
  run "uptime";
  my $s = last_command_output;
  ok($s =~ m/load/i, "Got last output");

  run "ls -l /";
  $s = last_command_output;
  ok($s !~ m/load/i, "Old output is not there anymore");
  ok($s =~ m/etc/, "found boot folder");

  done_testing();
};
