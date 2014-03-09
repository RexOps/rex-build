# vim: set syn=perl:
use Rex -feature => ['0.42', 'source_profile'];

use Rex::Commands::MD5;
use Data::Dumper;
use Test::More;

do "auth.conf";

task "test", group => "test", sub {

  my $in = run 'echo $MYFOO';
  ok($in eq "MYBAR", "got .profile variable");

  done_testing();
};

