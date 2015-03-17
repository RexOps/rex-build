# vim: set syn=perl:
use Test::More;

do "auth.conf";

task test => group => test => sub {
  my $s = run "echo \$PATH",
    env => {
      PATH => "/bin:/usr/bin:/tmp/bin",
    };

  is($s, "/bin:/usr/bin:/tmp/bin", "return value of PATH is ok.");

  done_testing();
};

1;
