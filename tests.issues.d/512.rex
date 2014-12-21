# vim: set syn=perl:
use Test::More;
use Rex::Commands::Fs;
use Rex::Commands::Sync;

do "auth.conf";

task test => group => test => sub {

  # prepare test
  file '/tmp/foo',
    ensure => 'directory';
  file '/tmp/foo/test@rex.txt',
    content => 'only a test';
  file '/tmp/foo/test$rex.txt',
    content => 'only a test';
  file '/tmp/foo/test%rex{abc}.txt',
    content => 'only a test';

  # run sync_down
  LOCAL { mkdir 'foo'; };
  my $has_error = 0;
  eval {
    sync_down '/tmp/foo', 'foo';
    is(-f 'foo/test@rex.txt', 1, 'file with @ symbol');
    is(-f 'foo/test$rex.txt', 1, 'file with $ symbol');
    is(-f 'foo/test%rex{abc}.txt', 1, 'file with % symbol');
    1;
  } or do {
    $has_error = 1;
  };

  is($has_error, 0, "sync_down with special symbols successfull");

  LOCAL { rmdir 'foo'; };

  done_testing();
};
