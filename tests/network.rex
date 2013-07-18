# vim: set syn=perl:

use Rex -feature => '0.42';
use Rex::Commands::Network;
use Data::Dumper;
use Test::More;

user $ENV{REXUSER};
password $ENV{REXPASS};
pass_auth;

if(exists $ENV{use_sudo}) {
   sudo_password $ENV{REXPASS};
   sudo -on;
}

group test => $ENV{HTEST};

task "test", group => "test", sub {

   my @route = route;
   #print Dumper(\@route);

   #say ">> " . default_gateway;
   ok(default_gateway() eq "192.168.112.1", "Default Gateway");

   #my @netstat = netstat;
   #print Dumper(\@netstat);
   my @tcp_connections = grep { $_->{"proto"} eq "tcp" } netstat;

   if(is_linux) {
      my ($ssh) = grep { $_->{command} =~ /^sshd/ } @tcp_connections;
      ok($ssh, "found sshd");
   }
   else {
      my ($ssh) = grep { $_->{local_addr} =~ /\.22$/ } @tcp_connections;
      ok($ssh, "found sshd");
   }

   done_testing();
};
