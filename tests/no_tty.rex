# vim: set syn=perl:
use Rex -feature => '0.42';
use strict;
use warnings;

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
}

group test => $ENV{HTEST};


task "test", group => "test", sub {

   Rex::Config->set_no_tty(0);
   my $out = run "ls -l /sdfjkl";
   ok($out =~ m/cannot access|No such file or directory/gms, "ls on wrong directory - with tty");

   Rex::Config->set_no_tty(1);
   $out = run "ls -l /sdfjkl";
   ok($out !~ m/cannot access|No such file or directory/gms, "ls on wrong directory - with no_tty");

   Rex::Config->set_no_tty(0);
   $out = run "ls -l /sdfjkl";
   ok($out =~ m/cannot access|No such file or directory/gms, "ls on wrong directory - with tty no2");


   Rex::Config->set_no_tty(1);
   run "ls -l / /dfgdfg", sub {
      my ($stdout, $stderr) = @_;
      ok($stdout =~ m/tmp/gms, "found tmp folder");
      ok($stderr =~ m/No such file/, "got error message");
   };

   done_testing();

};
