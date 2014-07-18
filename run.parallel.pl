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

my $yaml =
  eval { local ( @ARGV, $/ ) = ( $ENV{HOME} . "/.build_config" ); <>; };
$yaml .= "\n";
my $config = Load($yaml);

cloud_service "Jiffybox";
cloud_auth $config->{jiffybox}->{auth}->{access_key};

user "root";
password $config->{jiffybox}->{auth}->{password};


my @instances;
my @ips;
for my $i (1 .. 10) {
  my $instance = cloud_instance create => {
    image_id => "debian_squeeze_64bit",
    name     => "ptest$i",
    plan_id  => 29,
    password => $config->{jiffybox}->{auth}->{password},
  };

  push @instances, $instance;
  push @ips, $instance->{ip};
}

$::ip = undef;
$::ip = join(" ", @ips);

parallelism 50;

do "run.tests.pl";

for my $i (1 .. $config->{parallelism}) {
  cloud_instance terminate => $i->{id};
}

my @running = grep { lc($_->{state}) eq "running" } cloud_instance_list;

if(scalar @running >= 1) {
  die "There are still some instances running...";
}

exit 0;
