# vim: set syn=perl:

use Rex -feature => '0.42';
use IO::All;
use Test::More;

do "auth.conf";

user "nothing";
password "nothing";
key_auth;

auth
  fallback => {
  user      => "no",
  password  => "nada",
  auth_type => "key",
  },
  {
  user      => "nope",
  password  => "senseless",
  auth_type => "pass",
  },
  {
  user      => $ENV{REXUSER},
  password  => $ENV{REXPASS},
  auth_type => "pass",
  };

task test => group => test => sub {
  ok( connection->server ne "<local>", "connection is not local" );
  ok( Rex::is_ssh,                     "connection is ssh" );

  done_testing();
};

1;
