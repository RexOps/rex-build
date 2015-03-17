# vim: set syn=perl:
use Test::More;

do "auth.conf";

task test => group => test => sub {
  my @group;
  eval {
    @group = connection->server->group;
  };

  is($group[0], "test", "server group is set.");

  done_testing();
};

1;
