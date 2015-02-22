# vim: set syn=perl:
use Test::More;
use Rex::Commands::Fs;

do "auth.conf";
Rex::Config->set_autodie(0); # emulate Rex version < 0.56

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

  is($has_error, 0, 'file() resource got NO error');

  done_testing();
};
