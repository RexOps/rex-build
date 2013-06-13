use Rex -feature => '0.42';
use Test::More;

user "root";
password "box";
pass_auth;

group test => $ENV{HTEST};

task test => group => test => sub {
   ok(1==1, "task is running");
   ok(connection->server eq $ENV{HTEST}, "connected to $ENV{HTEST}");

   my $out = run "id";
   ok($out =~ /uid=0\(root\) gid=0\(root\)/, "logged in as root");

   done_testing();
};

