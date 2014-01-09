# vim: set syn=perl:

use Rex -feature => '0.42';
use lib "../lib";
use PkgBuilder;
use Test::More;

do "auth.conf";

task test => group => test => sub {
   my $ok;

   my $op   = get_os_name;
   my $arch = get_os_arch;
   my $ver  = get_os_release;

   eval {
      $ok = 0;
      repository add => "rex", (distro => $ver), %{ config->{repo}->{add}->{lc($op)}->{$ver}->{$arch} }; 
      $ok = 1;
   } or do {
      eval { repository remove => "rex"; };
   };
   ok($ok == 1, "repository added");

   eval {
      $ok = 0;
      update_package_db();
      $ok = 1;
   };
   ok($ok == 1, "update package db");

   eval {
      $ok = 0;
      install "rex";
      $ok = 1;
   };
   ok($ok == 1, "rex installed");

   my $out = run "rex -v";
   ok($? == 0, "run rex");
   ok($out =~ m/\d+\.\d+\.\d+/, "got version");

   done_testing();
};

