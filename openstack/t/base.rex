use strict;
use warnings;

use Rex::Commands::Cloud;
use Rex::Commands::SimpleCheck;
use Rex::Commands::SCM;
use Rex::Commands::Iptables;
use Test::More;
use Data::Dumper;
use YAML;

my $yaml =
  eval { local ( @ARGV, $/ ) = ( $ENV{HOME} . "/.build_config" ); <>; };
$yaml .= "\n";
my $config = Load($yaml);

cloud_service "OpenStack";
cloud_auth %{ $config->{openstack}->{auth} };
cloud_region $config->{openstack}->{endpoint};

user "root";
private_key $config->{amazon}->{auth}->{private_key};
public_key $config->{amazon}->{auth}->{public_key};

task test => sub {
  my $param = shift;

  my @images = cloud_image_list;
  ok( $images[0]->{name} eq 'cirros-0.3.1-x86_64-uec',
    "Got first cloud image." );

  done_testing();
};

1;
