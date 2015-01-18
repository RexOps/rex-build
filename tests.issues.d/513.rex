# vim: set syn=perl:
use Test::More;
use Rex::Commands::Fs;
use Rex::Commands::Sync;

do "auth.conf";

task test => group => test => sub {
  ok(1==1, "Rexfile executed and run");
  done_testing();
};


# simulate #513 bug
0;

