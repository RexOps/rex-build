# vim: set syn=perl:
use Rex -feature => '0.56';
use Test::More;
use Rex::Commands::Fs;

do "auth.conf";

task test => group => test => sub {

  my $has_error = 0;

  eval {
    file "/tmp/issue498",
      ensure => "directory",
      mode   => 999;
    1;
  } or do {
    $has_error = 1;
  };

  is($has_error, 1, 'file() resource got an error');

  done_testing();
};
