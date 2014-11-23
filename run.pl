#!/usr/bin/env perl

use YAML;
use Data::Dumper;
use Rex -base;
use Rex::Commands::Virtualization;
use Rex::Commands::SimpleCheck;
use Cwd 'getcwd';
use Mojo::UserAgent;

set virtualization => "LibVirt";

my $ua = Mojo::UserAgent->new;

$::QUIET = 1;
my $starttime;
my $phase;

our $branch   = $ENV{REX_BRANCH} || "master";
our $git_repo = $ENV{GIT_REPO}   || "git\@github.com:RexOps/Rex.git";

start_phase('Initializing');

my $yaml =
  eval { local ( @ARGV, $/ ) = ( $ENV{HOME} . "/.build_config" ); <>; };
$yaml .= "\n";
our $config = Load($yaml);

my $base_vm = $ARGV[0];
my $new_vm  = "${base_vm}-test-$$";
$new_vm =~ s/:/_/gms;

#Rex::connect( %{$config} );

&end_phase;

my $vm_info;

## try cloning until end of time
#my $new_vm;
#my $vm_cloned;
#
#my $try = 0;
#while ( !$vm_cloned ) {
#  $try++;
#  $new_vm = "${base_vm}-test-$$-$try";
#  if ( exists $ENV{use_sudo} ) {
#    $new_vm .= "-sudo";
#  }
#
#  start_phase('Cloning VM');
#  vm clone => $base_vm => $new_vm;
#  if($? == 0) {
#    $vm_cloned = 1;
#  }
#
#  eval {
#    my $vm_info = vm info => $new_vm;
#    1;
#  };
#
#  &end_phase;
#}
#
##run "/usr/bin/virt-clone --connect qemu:///system -o '$base_vm' -n '$new_vm' --auto-clone -f /ram/$new_vm.img";
#
#start_phase('Starting VM');
#my $vm_started = 0;
#for (qw/1 2 3/) {
#  eval { vm start => $new_vm; $vm_started = 1; };
#}
#&end_phase;
#
#if ( $vm_started == 0 ) {
#  die("Can't start vm: $new_vm.");
#}
#
#start_phase('Getting VM info');
#my $vminfo = vm guestinfo => $new_vm;
#our $ip = $vminfo->{network}->[0]->{ip};
#&end_phase;

start_phase('Creating test VM');

our $ip;

my $con_str =
    "http://$config->{jobcontrol}->{user}:$config->{jobcontrol}->{password}\@"
  . "$config->{jobcontrol}->{host}:$config->{jobcontrol}->{port}"
  . "/api/1.0/project/5bde00a59817c6e3e6e79cc4ad8a514a/node";

my $tx = $ua->post(
  $con_str,
  json => {
    name => $new_vm,
    type => "docker",
    parent =>
      "3a7f1fc9e58a8492fc625d8a16e85e76_c5fd214cdd0d2b3b4272e73b022ba5c2",
    data => {
      image => $base_vm,
      host =>
"3a7f1fc9e58a8492fc625d8a16e85e76_1b21b0d71706897b69f108572c444d40_b0da275520918e23dd615e2a747528f1",
      command => "/usr/sbin/sshd -D",
    }
  }
);

if ( $tx->success ) {
  my $ref = $tx->res->json;

  my $docker_id = $ref->{id};
  if ( !$docker_id ) {
    die "Error creating test VM";
  }

  my $qtx = $ua->get("$con_str/$docker_id");
  if ( $qtx->success ) {
    my $qref = $qtx->res->json;
    $ip = $qref->{provisioner}->[0]->{NetworkSettings}->{IPAddress};
  }
  else {
    die "Error getting info of test VM";
  }
}
else {
  die "Error creating test VM";
}

&end_phase;

if ( !$ip ) {
  die "Error couldn't get IP address.";
}

start_phase('Wating for VM SSH port wakeup');
while ( !is_port_open( $ip, 22 ) ) {
  sleep 1;
}
&end_phase;

our ( $user, $pass );

if ( exists $ENV{use_sudo} ) {
  $user = $config->{box}->{sudo}->{user};
  $pass = $config->{box}->{sudo}->{password};
}
else {
  $user = $config->{box}->{default}->{user};
  $pass = $config->{box}->{default}->{password};
}

do "run.tests.pl";

start_phase('Cleaning up VM');
vm destroy => $new_vm;

vm delete => $new_vm;

#rm "/ram/$new_vm.img";
# fix for #6
run "virsh vol-delete --pool default $new_vm.img";
&end_phase;

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
  printf '%-50s', $phase;
}

sub end_phase {
  printf "%4u s\n", scalar( time - $starttime );
}
