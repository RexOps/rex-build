use Rex -feature => 0.42;
use Test::More;

user $ENV{REXUSER};
password $ENV{REXPASS};
pass_auth;

if(exists $ENV{use_sudo}) {
   sudo_password $ENV{REXPASS};
   sudo -on;
}

group test => $ENV{HTEST};


require Foo;
require Foo::Bar::Gee;


task "test", group => "test", sub {

   Foo::bar();
   Foo::Bar::Gee::test();

   done_testing();

};

1;
