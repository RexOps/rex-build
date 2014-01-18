# vim: set syn=perl:

use Rex -feature => '0.42';

use Rex::Commands::Network;
use Data::Dumper;
use Test::More;
use Rex::Hardware::Network;

do "auth.conf";

task "test", group => "test", sub {
   my $net = Rex::Hardware::Network->get;

   my @devs = @{ $net->{networkdevices} };
   ok(@{$net->{networkdevices}} ~~ m/(eth0|em0|e1000g0)/, "Found $1");
   my $dev = $1;
   ok(scalar (grep { m/eth|em|e1000/ } @devs) >= 1, "count of devs ok");
   my ($g_dev) = grep { m/\Q$dev\E/ } @{ $net->{networkdevices} };
   ok($g_dev eq $dev, "found $dev");
   ok($net->{networkconfiguration}->{$dev}->{ip} =~ m/^192\.168\.112\./, "found ip of $dev");
   ok($net->{networkconfiguration}->{$dev}->{netmask} =~ m/^255.\.255\.255\./, "found netmask of $dev");

   done_testing();
};

