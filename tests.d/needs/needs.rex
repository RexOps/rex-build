# vim: set syn=perl:
use Rex -feature => 0.42;
use Test::More;

do "auth.conf";

require Foo;

task "test", group => "test", sub {
   Foo::setup();

   ok(get("NEEDED") == 1, "need_test had ran");
   ok(get("NEEDED2") == 2, "need_test2 had ran - needs without main package");

   done_testing();
};

task "need_test", sub {

   set NEEDED => 1;

};

task "need_test2", sub {

   set NEEDED2 => 1;

};
