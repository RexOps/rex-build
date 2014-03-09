# vim: set syn=perl:

use Rex -feature => '0.42';
use Test::More;

do "auth.conf";

task test => group => test => sub {

  my @ret = run_batch "batch_test", on => connection->server;

  is($ret[0], "b1", "task b1 was run");
  is($ret[1], "b2", "task b2 was run");
  is($ret[2], "b3", "task b3 was run");

  ok(is_file("/tmp/b1.txt"), "b1.txt found");
  ok(is_file("/tmp/b2.txt"), "b2.txt found");
  ok(is_file("/tmp/b3.txt"), "b3.txt found");

  done_testing();
};

task b1 => sub {
  file "/tmp/b1.txt",
    content => "one";

  return "b1";
};

task b2 => sub {
  file "/tmp/b2.txt",
    content => "two";

  return "b2";
};

task b3 => sub {
  file "/tmp/b3.txt",
    content => "three";

  return "b3";
};

batch batch_test => "b1", "b2", "b3";
