# vim: set syn=perl:
use Rex -feature => ['0.42', 'no_path_cleanup', 'source_profile'];

use Rex::Commands::MD5;
use Data::Dumper;
use Test::More;

do "auth.conf";

task "test", group => "test", sub {

  my $in = run 'echo $PATH';
  ok($in eq "/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/blub", "path modified through .profile");

  done_testing();
};

