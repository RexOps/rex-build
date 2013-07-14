# vim: set syn=perl:

use Rex -feature => '0.42';
use Test::More;

user $ENV{REXUSER};
password $ENV{REXPASS};
pass_auth;

if(exists $ENV{use_sudo}) {
   sudo_password $ENV{REXPASS};
   sudo -on;
}

group test => $ENV{HTEST};


task "test", group => "test", sub {

   my @c = grep { is_file($_) } glob ("/etc/p*");

   ok("/etc/passwd" ~~ @c, "found /etc/passwd");

   done_testing();
};


