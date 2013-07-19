# vim: set syn=perl:
use Rex -feature => '0.42';
use Test::More;
use Data::Dumper;

user $ENV{REXUSER};
password $ENV{REXPASS};
pass_auth;

if(exists $ENV{use_sudo}) {
   sudo_password $ENV{REXPASS};
   sudo -on;
}

if(exists $ENV{openssh}) {
   set connection => 'OpenSSH';
   Rex::Config->set_openssh_opt(StrictHostKeyChecking => "no");
}

group test => $ENV{HTEST};

no_ssh task "test", group => "test", sub {
   ok(ref(connection) eq "Rex::Interface::Connection::Fake", "opened a fake connection");

   done_testing();
};