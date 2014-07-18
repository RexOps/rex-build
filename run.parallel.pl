#!/usr/bin/env perl

use strict;
use warnings;

use Rex -base;
use Rex::Commands::Cloud;
use Rex::Commands::SimpleCheck;
use Rex::Commands::SCM;
use Rex::Commands::Iptables;
use Test::More;
use Data::Dumper;
use YAML;
use Cwd 'getcwd';


$::QUIET = 1;
my $starttime;
my $phase;

our $branch = $ENV{REX_BRANCH} || "master";
our $git_repo = $ENV{GIT_REPO} || "git\@github.com:RexOps/Rex.git";

my $yaml =
  eval { local ( @ARGV, $/ ) = ( $ENV{HOME} . "/.build_config" ); <>; };
$yaml .= "\n";
our $config = Load($yaml);

cloud_service "Jiffybox";
cloud_auth $config->{jiffybox}->{auth}->{access_key};

my @instances;
my @ips;
for my $i ( 1 .. $config->{parallelism} ) {
  start_phase("Creating test instance: $i");

  my $instance = cloud_instance create => {
    image_id => "debian_squeeze_64bit",
    name     => "ptest$i",
    plan_id  => 29,
    password => $config->{jiffybox}->{auth}->{password},
  };

  push @instances, $instance;
  push @ips,       $instance->{ip};

  &end_phase;
}

our $user = "root";
our $pass = $config->{jiffybox}->{auth}->{password};
our $ip = join( " ", @ips );

parallelism 50;

do "run.tests.pl";

my $i=1;
for my $inst ( @instances ) {
  start_phase("Terminating test instance: $i");

  cloud_instance terminate => $inst->{id};
  $i++;

  &end_phase;
}

my @running = grep { lc( $_->{state} ) eq "running" } cloud_instance_list;

if ( scalar @running >= 1 ) {
  die "There are still some instances running...";
}

exit 0;


sub start_phase {
  $phase     = shift;
  $starttime = time;
  local $| = 1;
  printf '%-50s', $phase;
}

sub end_phase {
  printf "%4u s\n", scalar( time - $starttime );
}
