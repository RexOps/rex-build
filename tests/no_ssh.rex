# vim: set syn=perl:
use Rex -feature => '0.42';
use Test::More;
use Data::Dumper;

do "auth.conf";

no_ssh task "test", group => "test", sub {
   ok(ref(connection) eq "Rex::Interface::Connection::Fake", "opened a fake connection");

   done_testing();
};
