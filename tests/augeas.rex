# vim: set syn=perl:
use Test::More;
use Rex::Commands::Augeas;
use Rex -feature => ['1.0'];

do "auth.conf";

task test => group => test => sub {
};


