#!/usr/bin/env perl

use YAML;
use Data::Dumper;
use Rex -base;
use Rex::Commands::SimpleCheck;
use Rex::Commands::Cloud;

#$::QUIET = 1;
my $starttime;
my $phase;

our $branch   = $ENV{REX_BRANCH} || "master";
our $git_repo = $ENV{REX_REPO}   || "https://github.com/RexOps/Rex.git";

start_phase('Initializing');

my $yaml = eval {
  local ( @ARGV, $/ ) =
    ( ( $ENV{HOME} || $ENV{USERPROFILE} ) . "/.build_config" );
  <>;
};
$yaml .= "\n";
our $config = Load($yaml);

my $base_vm = $ARGV[0];
my $time    = time;

my $access_key        = $config->{amazon}->{auth}->{access_key};
my $secret_access_key = $config->{amazon}->{auth}->{private_access_key};

cloud_service "Amazon";
cloud_auth $access_key, $secret_access_key;
cloud_region "ec2.eu-west-1.amazonaws.com";

our ( $user, $pass );

if ( exists $ENV{use_sudo} ) {
  $user = $config->{box}->{sudo}->{user};
  $pass = $config->{box}->{sudo}->{password};
}
else {
  $user = $config->{box}->{default}->{user};
  $pass = $config->{box}->{default}->{password};
}

&end_phase;

start_phase('Creating test VM');

our ( $vm_id, $ip ) = start_amazon($base_vm);

&end_phase;

if ( !$ip ) {
  die "Error couldn't get IP address.";
}

start_phase("Waiting for VM SSH port wakeup on $ip");
while ( !is_port_open( $ip, 22 ) ) {
  sleep 1;
}

sleep 5;
&end_phase;

my $RETVAL = 1;

eval {
  do "run.tests.pl";
  $RETVAL = 0;
  1;
} or do {
  print "\nERROR: $@\n";
};

start_phase('Cleaning up VM');

remove_amazon($vm_id);

&end_phase;

exit $RETVAL;

sub get_random {
  my $count = shift;
  my @chars = @_;

  srand();
  my $ret = "";
  for ( 1 .. $count ) {
    $ret .= $chars[ int( rand( scalar(@chars) - 1 ) ) ];
  }

  return $ret;
}

sub start_phase {
  $phase     = shift;
  $starttime = time;
  local $| = 1;
  printf '%-70s', $phase;
}

sub end_phase {
  printf "%4u s\n", scalar( time - $starttime );
}

sub start_amazon {
  my $image_id = shift;
  my $vm = cloud_instance create => {
    image_id       => $image_id,
    name           => "rhel01",
    key            => "integration-tests",
    type           => 't2.micro',
    security_group => 'default',
    options        => {
      SubnetId => 'subnet-0ac1f97d',
    }
  };

  return ( $vm->{id}, $vm->{ip} );
}

sub remove_amazon {
  my $instance_id = shift;
  cloud_instance terminate => $instance_id;
}
