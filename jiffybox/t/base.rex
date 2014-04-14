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

cloud_service "Jiffybox";
cloud_auth $config->{jiffybox}->{auth}->{access_key};

user "root";
password $config->{jiffybox}->{auth}->{password};

task test => sub {
  my $param = shift;

  my $instance = cloud_instance create => {
    image_id => "debian_squeeze_64bit",
    name     => "jiffy01",
    plan_id  => 29,
    password => $config->{jiffybox}->{auth}->{password},
  };

  ok( $instance->{name} eq "jiffy01", "got instance name" );

  my ($inst) =
    grep { ( $_->{name} eq "jiffy01" ) && ( lc($_->{state}) eq "running" ) }
    cloud_instance_list;

  ok( $inst->{name} eq "jiffy01",
    "got instance name from cloud_instance_list" );
  ok( lc($inst->{state}) eq "running", "got state running" );

  cloud_instance terminate => $inst->{id};

  $inst = undef;
  ($inst) = grep { ( $_->{name} eq "jiffy01" ) && ( lc($_->{state}) ne "running" ) }
    cloud_instance_list;
  
  ok( lc($inst->{state}) ne "running", "instance terminated" );

  done_testing();
};

1;
