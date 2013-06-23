use Rex -feature => '0.42';
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

task "test", group => "test", sub {

   Foo::bar();

   done_testing();
};

1;
