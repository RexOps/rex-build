# vim: set syn=perl:
use Test::More;

do "auth.conf";

group itest => split( / /, $ENV{HTEST} );

auth for => "itest" =>
  user => "rsync_user",
  password => 'rsync.pw',
  sudo_password => 'rsync.pw';

task test => group => test => sub {
  do_task "run_test";
  done_testing();
};

task "run_test", group => "itest", sub {
  sudo -on;
  my $userid = run "id -u";
  is($userid, 0, "got root id in same task.");

  sudo_test();
};

task "sudo_test", sub {
  my $userid = run "id -u";
  is($userid, 0, "got root id in next task");
};

