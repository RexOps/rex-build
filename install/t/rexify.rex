# vim: set syn=perl:

use Rex -feature => '0.42';
use Test::More;

do "auth.conf";

task test => group => test => sub {

  if($ENV{TEST_PACKAGE} eq "rex") {
    mkdir "/tmp/rexify-$$";
    run "cd /tmp/rexify-$$; rexify MyProject";
    ok($? == 0, "rexify command run without errors.");

    ok(-f "/tmp/rexify-$$/MyProject/Rexfile", "found Rexfile");
    ok(-f "/tmp/rexify-$$/MyProject/lib/MyProject.pm", "found MyProject.pm");

    my $c_rexfile = cat "/tmp/rexify-$$/MyProject/Rexfile";
    ok($c_rexfile =~ m/require MyProject/gm, "found right content in Rexfile");

    my $c_lib = cat "/tmp/rexify-$$/MyProject/lib/MyProject.pm";
    ok($c_lib =~ m/package MyProject/gm, "found right content in MyProject.pm");

    run "rm -rf /tmp/rexify-$$";
  }
  else {
    ok(1==1, "no tests");
  }

  done_testing();
};

