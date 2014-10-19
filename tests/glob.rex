# vim: set syn=perl:

use Rex -feature => '0.42';
use Test::More;

do "auth.conf";

task "test", group => "test", sub {

  my @c = grep { is_file($_) } glob ("/etc/p*");

  my ($passwd) = grep { m:/etc/passwd: } @c;
  ok($passwd, "found /etc/passwd");

  done_testing();
};


