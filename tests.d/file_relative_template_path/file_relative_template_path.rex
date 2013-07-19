# vim: set syn=perl:
use Rex -feature => 0.42;
use Test::More;


do "auth.conf";

require Foo;
require Foo::Bar::Gee;


task "test", group => "test", sub {

   Foo::bar();
   Foo::Bar::Gee::test();

   done_testing();

};

1;
