use Rex -feature => '0.42';

use Rex::Commands::Host;
use Test::More;

user $ENV{REXUSER};
password $ENV{REXPASS};
pass_auth;

if(exists $ENV{use_sudo}) {
   sudo_password $ENV{REXPASS};
   sudo -on;
}

group test => $ENV{HTEST};

task test => group => test => sub {

   my @hosts = get_host("localhost");

   my $ok=0;
   for my $entry (@hosts) {
      if($entry->{ip} eq "127.0.0.1") {
         $ok = 1;
      }
   }

   ok($ok == 1, "getting entry for localhost" );

   create_host "rexify.org", {
      ip => "1.2.3.4"
   };

   my @host = get_host("rexify.org");
   ok($host[0]->{host} eq "rexify.org", "setting hosts entry");

   create_host "rexify.org", {
      ip => "4.3.2.1",
      aliases => ["www.rexify.org", "www2.rexify.org"],
   };

   @host = get_host("www2.rexify.org");
   ok($host[0]->{ip} eq "4.3.2.1", "get ip of host");

   delete_host "rexify.org";

   ok(! get_host("rexify.org"), "delete host");

   done_testing();
};

