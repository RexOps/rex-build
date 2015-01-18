# vim: set syn=perl:
use Test::More;
use Rex::Commands::Sync;

do "auth.conf";

my $count = 0;

task test => group => test => sub {
};

around "test", sub {
  my ($server, $server_ref, $args, $position) = @_;

  if($count == 1) {
    is($position, 1, "around runs after the task");
    done_testing();
  }
  else {
    is($position, undef, "around runs before the task");
  }

  $count++;
};

1;
