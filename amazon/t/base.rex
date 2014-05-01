use strict;
use warnings;

use Rex::Commands::Cloud;
use Rex::Commands::SimpleCheck;
use Rex::Commands::SCM;
use Rex::Commands::Iptables;
use Test::More;
use Data::Dumper;
use YAML;


my $yaml = eval { local(@ARGV, $/) = ($ENV{HOME} . "/.build_config"); <>; };
$yaml .= "\n";
my $config = Load($yaml);

cloud_service "Amazon";
cloud_auth $config->{amazon}->{auth}->{access_key}, $config->{amazon}->{auth}->{private_access_key};
cloud_region $config->{amazon}->{region};

user "root";
private_key $config->{amazon}->{auth}->{private_key};
public_key $config->{amazon}->{auth}->{public_key};

task test => sub {
  my $param = shift;

  my $vol_id = cloud_volume create => { size => 1, zone => "eu-west-1a", };

  my $instance = cloud_instance create => {
         image_id => "ami-5187bb25",
         name    => "amaz01",
         key    => "brownbag",
         zone    => "eu-west-1a",
         type    => "m1.large",
         security_group => "alltcpfoo",
       };

  ok($instance->{name} eq "amaz01", "got instance name");
  ok($instance->{security_group} eq "alltcpfoo", "got security group");

  my ($inst) = grep { (exists $_->{name} && $_->{name} && $_->{name} eq "amaz01") && ($_->{state} eq "running") } cloud_instance_list;

  ok($inst->{name} eq "amaz01", "got instance name");
  ok($inst->{security_group} eq "alltcpfoo", "got security group");
  ok($inst->{state} eq "running", "got state running");

  cloud_instance terminate => $inst->{id};

  $inst = undef;
  ($inst) = grep { (exists $_->{name} && $_->{name} && $_->{name} eq "amaz01") && ($_->{state} ne "running") } cloud_instance_list;

  ok($inst->{state} ne "running", "instance terminated");

  my ($vol) = grep { $_->{id} eq $vol_id } cloud_volume_list;

  ok($vol->{id} eq $vol_id, "found cloud volume");
  ok($vol->{status} eq "available", "volum in use");

  cloud_volume delete => $vol->{id};

  $instance = cloud_instance create => {
         image_id => "ami-5187bb25",
         name    => "amaz02",
         key    => "brownbag",
         zone    => "eu-west-1a",
         type    => "m1.large",
         security_groups => ["alltcpfoo", "default"],
       };


  ($inst) = grep { (exists $_->{name} && $_->{name} && $_->{name} eq "amaz02") && ($_->{state} eq "running") } cloud_instance_list;

  ok($inst->{name} eq "amaz02", "got instance name");
  ok($inst->{security_group} eq "default,alltcpfoo", "got security groups");
  ok($inst->{state} eq "running", "got state running");
  ok($inst->{security_groups}->[0] eq "default", "got security groups (default)");
  ok($inst->{security_groups}->[1] eq "alltcpfoo", "got security groups (alltcpfoo)");

  cloud_instance terminate => $inst->{id};

  $inst = undef;
  ($inst) = grep { (exists $_->{name} && $_->{name} && $_->{name} eq "amaz02") && ($_->{state} ne "running") } cloud_instance_list;

  ok($inst->{state} ne "running", "instance terminated");


  done_testing();
};

1;
