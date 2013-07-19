# vim: set syn=perl:

use Rex -feature => '0.42';

use Rex::Commands::Network;
use Data::Dumper;
use Test::More;
use Rex::Hardware::Network;

user $ENV{REXUSER};
password $ENV{REXPASS};
pass_auth;

if(exists $ENV{use_sudo}) {
   sudo_password $ENV{REXPASS};
   sudo -on;
}

if(exists $ENV{openssh}) {
   set connection => 'OpenSSH';
   $Rex::Interface::Connection::OpenSSH::DISABLE_STRICT_HOST_CHECKING = 1;
}

group test => $ENV{HTEST};

task "test", group => "test", sub {
   my $net = Rex::Hardware::Network->get;

   my @devs = @{ $net->{networkdevices} };
   ok(@{$net->{networkdevices}} ~~ m/(eth0|em0|e1000g0)/, "Found $1");
   my $dev = $1;
   ok(scalar (grep { m/eth|em|e1000/ } @devs) >= 1, "count of devs ok");
   my ($g_dev) = grep { m/\Q$dev\E/ } @{ $net->{networkdevices} };
   ok($g_dev eq $dev, "found $dev");
   ok($net->{networkconfiguration}->{$dev}->{ip} =~ m/^192\.168\.112\./, "found ip of $dev");

   done_testing();
};

