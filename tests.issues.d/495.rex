# vim: set syn=perl:
use Test::More;
use Rex::Commands::Sync;

do "auth.conf";

task test => group => test => sub {

  ## prepare test
  file '/tmp/sync_down_excl', ensure => 'directory';
  file '/tmp/sync_down_excl/test.txt', content => 'only a file';
  file '/tmp/sync_down_excl/test.conf', content => 'only 2nd file';
  file '/tmp/sync_down_excl/test.conf.txt', content => 'only 3nd file';

  LOCAL {
    file 'sync_up', ensure => 'directory';
    file 'sync_up/test.txt', content => 'only a file';
    file 'sync_up/test.conf', content => 'only 2nd file';
    file 'sync_up/test.conf.txt', content => 'only 3nd file';
  };

  LOCAL { file 'sync_down', ensure => 'directory'; };

  sync_down '/tmp/sync_down_excl', 'sync_down', { exclude => ['*.conf'] };

  LOCAL {
    is(is_file('sync_down/test.txt'), 1, 'sync_down -> test.txt');
    is(is_file('sync_down/test.conf.txt'), 1, 'sync_down -> test.conf.txt');
    is(is_file('sync_down/test.conf'), undef, 'excluded: sync_down -> test.conf');
  };

  LOCAL { file 'sync_down', ensure => 'absent'; };

  file '/tmp/sync_up_excl', ensure => 'directory';
  sync_up 'sync_up', '/tmp/sync_up_excl', { exclude => ['*.conf'] };

  is(is_file('/tmp/sync_up_excl/test.txt'), 1, 'sync_up -> test.txt');
  is(is_file('/tmp/sync_up_excl/test.conf.txt'), 1, 'sync_up -> test.conf.txt');
  is(is_file('/tmp/sync_up_excl/test.conf'), undef, 'excluded: sync_up -> test.conf');

  LOCAL { file 'sync_up', ensure => 'absent'; };

  done_testing();
};
