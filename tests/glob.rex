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

if(exists $ENV{openssh}) {
   set connection => 'OpenSSH';
   $Rex::Interface::Connection::OpenSSH::DISABLE_STRICT_HOST_CHECKING = 1;
}

group test => $ENV{HTEST};


task "test", group => "test", sub {

   my @c = grep { is_file($_) } glob ("/etc/p*");

   ok("/etc/passwd" ~~ @c, "found /etc/passwd");

   done_testing();
};


