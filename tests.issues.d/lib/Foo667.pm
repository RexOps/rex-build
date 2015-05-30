package Foo667;

use Rex -base;
use Test::More;

my $before_task_start = 0;

task "uptime", group => "test", sub {
  is($before_task_start, 1, "before_task_start was executed");
};

before_task_start "uptime", sub {
  $before_task_start = 1;
};

1;
