# vim: set syn=perl:
use Test::More;
use Rex::Helper::Path;

our $filename = Rex::Helper::Path::get_tmp_file();

do 'auth.conf';

task test => group => test => sub {
  run_task "foo", on => connection->server;
  ok(is_file($filename), 'foo ran on remote');
};

task "foo" => sub {
  run "touch $filename";
};

before_task_start "ALL" => sub {};

1;
