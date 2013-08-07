# vim: set syn=perl:
use Rex -feature => 0.42;
use Test::More;

do "auth.conf";

require Foo;

task "test", group => "test", sub {

   if(is_openwrt) {
      # skip this test for now
      ok(1==1, "no openwrt tests");
      done_testing();
      return;
   }

   Foo::bar();

   done_testing();

};

1;
