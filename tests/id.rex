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
   Rex::Config->set_openssh_opt(StrictHostKeyChecking => "no");
}

group test => $ENV{HTEST};


task "test", group => "test", sub {
   my $id = run "id";
   
   ok($id =~ m/uid=0\(root\)/, "i'm root");

   done_testing();
};

