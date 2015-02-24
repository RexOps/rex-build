# vim: set syn=perl:

use IO::All;
use Rex -feature => '0.42';
use Test::More;

do "auth.conf";

parallelism 1;

task test => sub {
  do_task [qw/test2/];

  my $count_before < io "before.cnt";
  my $count_after  < io "after.cnt";
  my $count_before_task < io "before_task_start.cnt";
  my $count_after_task  < io "after_task_finished.cnt";

  print "\n\n>>>> $count_before / $count_after / $count_before_task / $count_after_task\n\n";

  ok($count_before == 2, "before hook runs 2 times");
  ok($count_after == 2, "after hook runs 2 times");
  ok($count_before_task == 1, "before_task_start hook runs 1 time");
  ok($count_after_task == 1, "after_task_finished hook runs 1 time");

  done_testing();

  run "rm *.cnt";
};

task test2 => group => ["test", "test"] => sub {
};

before test2 => sub {
  my @content;
  eval { @content = io("before.cnt")->slurp; };
  my $count = $content[0] || 0;
  $count++;
  $count > io "before.cnt";
};

after test2 => sub {
  my @content;
  eval { @content = io("after.cnt")->slurp; };
  my $count = $content[0] || 0;
  $count++;
  $count > io "after.cnt";
};

before_task_start "test2", sub {
  my @content;
  eval { @content = io("before_task_start.cnt")->slurp; };
  my $count = $content[0] || 0;
  $count++;
  $count > io "before_task_start.cnt";
};

after_task_finished "test2", sub {
  my @content;
  eval { @content = io("after_task_finished.cnt")->slurp; };
  my $count = $content[0] || 0;
  $count++;
  $count > io "after_task_finished.cnt";
};

1;
