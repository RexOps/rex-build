# vim: set syn=perl:

use Rex -feature => '0.42';
use Test::More;

do "auth.conf";

task "test", group => "test", sub {
   my $id = run "id";
   
   ok($id =~ m/uid=0\(root\)/, "i'm root");

   done_testing();
};


