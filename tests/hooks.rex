# vim: set syn=perl:

use IO::All;
use Rex -feature => '0.42';
use Test::More;

do "auth.conf";
my $path = "/tmp/h-$$";
CORE::mkdir($path);

parallelism 1;

task test => sub {
  my $zero = "0";
  LOCAL {
    eval {
      $zero > io "$path/before.cnt";
      $zero > io "$path/after.cnt";
      $zero > io "$path/before_task_start.cnt";
      $zero > io "$path/after_task_finished.cnt";
    };
  };

  do_task [qw/hooktask/];

  my $count_before < io "$path/before.cnt";
  my $count_after  < io "$path/after.cnt";
  my $count_before_task < io "$path/before_task_start.cnt";
  my $count_after_task  < io "$path/after_task_finished.cnt";

  print "\n\n>>>> $count_before / $count_after / $count_before_task / $count_after_task\n\n";

  ok($count_before == 2, "before hook runs 2 times");
  ok($count_after == 2, "after hook runs 2 times");
  ok($count_before_task == 1, "before_task_start hook runs 1 time");
  ok($count_after_task == 1, "after_task_finished hook runs 1 time");

  done_testing();

  LOCAL {
    eval {
      CORE::unlink("$path/before.cnt");
      CORE::unlink("$path/after.cnt");
      CORE::unlink("$path/before_task_start.cnt");
      CORE::unlink("$path/after_task_finished.cnt");
    };
  };
};

task hooktask => group => ["test", "test"] => sub {
};

before hooktask => sub {
  my @content;
  eval { @content = io("$path/before.cnt")->slurp; };
  my $count = $content[0] || 0;
  $count++;
  $count > io "$path/before.cnt";
};

after hooktask => sub {
  my @content;
  eval { @content = io("$path/after.cnt")->slurp; };
  my $count = $content[0] || 0;
  $count++;
  $count > io "$path/after.cnt";
};

before_task_start "hooktask", sub {
  my @content;
  eval { @content = io("$path/before_task_start.cnt")->slurp; };
  my $count = $content[0] || 0;
  $count++;
  $count > io "before_task_start.cnt";
};

after_task_finished "hooktask", sub {
  my @content;
  eval { @content = io("$path/after_task_finished.cnt")->slurp; };
  my $count = $content[0] || 0;
  $count++;
  $count > io "$path/after_task_finished.cnt";
};

1;
