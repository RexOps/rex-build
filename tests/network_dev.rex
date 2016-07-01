# vim: set syn=perl:

use Rex -feature => '0.42';

use Rex::Commands::Network;
use Data::Dumper;
use Test::More;
use Rex::Hardware::Network;
use List::Util qw'first';

do "auth.conf";

task "test", group => "test", sub {
  my $net = Rex::Hardware::Network->get;

  my @devs = @{ $net->{networkdevices} };
  my ($dev) = first { $_ =~ m/^(eth0|em0|e1000g0|xn0)$/ } @{$net->{networkdevices}};
  ok($dev, "Found $dev");

  ok(scalar (grep { m/eth|em|e1000|xn0/ } @devs) >= 1, "count of devs ok");

  ok($net->{networkconfiguration}->{$dev}->{ip} =~ m/^\d+\.\d+\.\d+\./, "found ip of $dev");
  ok($net->{networkconfiguration}->{$dev}->{netmask} =~ m/^\d+\.\d+\.\d+\./, "found netmask of $dev");

  # not working inside a container
  #ok($net->{networkconfiguration}->{"$dev:1"}->{ip} eq "1.2.3.4", "found ip of $dev:1");
  #ok($net->{networkconfiguration}->{"$dev:1"}->{netmask} eq "255.255.255.255", "found netmask of $dev:1");

  done_testing();
};
