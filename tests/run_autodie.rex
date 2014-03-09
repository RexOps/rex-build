# vim: set syn=perl:

use Rex -feature => ['0.42', 'exec_autodie'];
use Test::More;

do "auth.conf";

task test => group => test => sub {

  eval {
    run "this-command-fails";
  } or do {
    ok($@, "run command died");
  };

  done_testing();
};

