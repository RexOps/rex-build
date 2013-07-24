# vim: set syn=perl:

use Rex -feature => '0.42';
use Test::More;

do "auth.conf";

task "test", group => "test", sub {

   if(is_openwrt) {
      # skip this test for now
      ok(1==1, "no openwrt tests");
      done_testing();
      return;
   }


   my @c = grep { is_file($_) } glob ("/etc/p*");

   ok("/etc/passwd" ~~ @c, "found /etc/passwd");

   done_testing();
};


