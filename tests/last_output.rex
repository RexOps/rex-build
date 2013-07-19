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
   run "uptime";
   my $s = last_command_output;
   ok($s =~ m/load/i, "Got last output");

   run "ls -l /";
   $s = last_command_output;
   ok($s !~ m/load/i, "Old output is not there anymore");
   ok($s =~ m/boot/, "found boot folder");

   done_testing();
};
