# vim: set syn=perl:

use Rex -feature => '0.42';
use Data::Dumper;
use Rex::Commands::Gather;
use Test::More;

do "auth.conf";

desc "Get Hardware Information";
task "test", group => "test", sub {


   my %hw = Rex::Hardware->get(qw/ Host Kernel Memory Network Swap /);

   ok(@{$hw{Network}->{networkdevices}} ~~ m/(eth0|em0|e1000g0)/, "Found $1");
   my $dev = $1;
   ok($hw{Network}->{networkconfiguration}->{"$dev"}->{"ip"} =~ m/^(192|10)\./, "Got IP for $dev");
   ok($hw{Network}->{networkconfiguration}->{"$dev"}->{"netmask"} =~ m/255\.|ff/, "Got Netmask for $dev");
   ok($hw{Network}->{networkconfiguration}->{"$dev"}->{"mac"} =~ m/^(00:|0:|52:)/, "Got MAC for $dev");

   ok($hw{Memory}->{free} > 1, "Got free memory");
   ok($hw{Memory}->{used} > 1, "Got used memory");
   ok($hw{Memory}->{total} >= 450, "Got total memory");

   ok(defined $hw{Kernel}->{kernel}, "Got kernel");
   ok(defined $hw{Kernel}->{kernelversion}, "Got kernel version");
   ok(defined $hw{Kernel}->{architecture}, "Got kernel architecture");

   if(!is_openwrt) {
      ok($hw{Swap}->{total} > 1, "Got total swap");
      ok($hw{Swap}->{used} >= 0, "Got used swap");
      ok($hw{Swap}->{free} >= 100, "Got free swap");
   }

   done_testing();
};


