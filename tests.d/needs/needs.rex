# vim: set syn=perl:
use Rex -feature => 0.42;
use Test::More;

do "auth.conf";

require Foo;

task "test", group => "test", sub {
   Foo::setup();

   ok(get("NEEDED") == 1, "need_test had ran");

   done_testing();
};

task "need_test", sub {

   set NEEDED => 1;

};
