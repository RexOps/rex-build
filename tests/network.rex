# vim: set syn=perl:

use Rex -feature => '0.42';
use Rex::Commands::Network;
use Data::Dumper;
use Test::More;

do "auth.conf";

task "test", group => "test", sub {

  my @route = route;
  #print Dumper(\@route);

  #say ">> " . default_gateway;
  ok(default_gateway() =~ /^\d+\.\d+\.\d+\.\d+$/, "Default Gateway");

  #my @netstat = netstat;
  #print Dumper(\@netstat);
  my @tcp_connections = grep { $_->{"proto"} eq "tcp" } netstat;

  if(is_openwrt) {
    my ($ssh) = grep { $_->{command} =~ /dropbear/ } @tcp_connections;
    ok($ssh, "found sshd");
  }
  else {
    my ($ssh) = grep { $_->{local_addr} =~ /[\.:]22$/ } @tcp_connections;
    ok($ssh, "found sshd");
  }

  done_testing();
};
