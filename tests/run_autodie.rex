# vim: set syn=perl:

use Rex -feature => ['0.42', 'exec_autodie'];
use Test::More;

do "auth.conf";

task test => group => test => sub {

  eval {
    run "this-command-fails";
  } or do {
    ok($@, "run command died");
  };

  # tests for #392
  my $died = 0;
  eval {
    run "ls -l", unless => "this-command-doesnt-exists";
    1;
  } or do {
    $died = 1;
  };
  ok($died == 0, "don't die with failed unless command.");

  $died = 0;
  eval {
    run "xls -l", unless => "this-command-doesnt-exists";
    1;
  } or do {
    $died = 1;
  };
  ok($died == 1, "die with failed unless command and failed command");

  $died = 0;
  eval {
    run "ls -l", only_if => "id";
    1;
  } or do {
    $died = 1;
  };
  ok($died == 0, "don't die with successfull only_if command");

  $died = 0;
  eval {
    run "ls -l", only_if => "xid";
    1;
  } or do {
    $died = 1;
  };
  ok($died == 0, "don't die with failed only_if command");

  $died = 0;
  eval {
    run "xls -l", only_if => "id";
    1;
  } or do {
    $died = 1;
  };
  ok($died == 0, "die with successfull only_if command");



  done_testing();
};

