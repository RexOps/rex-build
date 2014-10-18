# vim: set syn=perl:

use Rex -feature => '0.42';
use Data::Dumper;
use Rex::Commands::Gather;
use Test::More;

do "auth.conf";

desc "Get Hardware Information";
task "test", group => "test", sub {


  my %hw = Rex::Hardware->get(qw/ Host Kernel Memory Network Swap /);

  ok(grep { m/(eth0|em0|e1000g0)/ } @{$hw{Network}->{networkdevices}}, "Found $1");
  my $dev = $1;
  ok($hw{Network}->{networkconfiguration}->{"$dev"}->{"ip"} =~ m/^(\d+)\./, "Got IP for $dev");
  ok($hw{Network}->{networkconfiguration}->{"$dev"}->{"netmask"} =~ m/\d+\.|ff/, "Got Netmask for $dev");
  ok($hw{Network}->{networkconfiguration}->{"$dev"}->{"mac"} =~ m/^([a-f0-9]+:[a-f0-9]+:)/i, "Got MAC for $dev");

  ok($hw{Memory}->{free} > 1, "Got free memory");
  ok($hw{Memory}->{used} > 1, "Got used memory");
  ok($hw{Memory}->{total} >= 450, "Got total memory");

  ok(defined $hw{Kernel}->{kernel}, "Got kernel");
  ok(defined $hw{Kernel}->{kernelversion}, "Got kernel version");
  ok(defined $hw{Kernel}->{architecture}, "Got kernel architecture");

  ok($hw{Swap}->{total} > 1, "Got total swap");
  ok($hw{Swap}->{used} >= 0, "Got used swap");
  ok($hw{Swap}->{free} >= 0, "Got free swap");

  done_testing();
};
