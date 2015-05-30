# vim: set syn=perl:
use Test::More;

do "auth.conf";

use lib "tests.issues.d/lib";

include qw/Foo667/;

use Rex::Transaction;

task test => group => test => sub {

  # create a symlink

  transaction {    # transaction for no fork
    do_task "Foo667:uptime";
    done_testing();
  };
};

1;
