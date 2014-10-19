#!/usr/bin/env perl

use YAML;
use Data::Dumper;
use Rex -base;
use Rex::Commands::Virtualization;
use Rex::Commands::SimpleCheck;
use Cwd 'getcwd';

set virtualization => "LibVirt";

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

Rex::connect( %{$config} );

my $new_vm = "${base_vm}-test-$$";
if ( exists $ENV{use_sudo} ) {
  $new_vm .= "-sudo";
}

&end_phase;

my $vm_info;

# try cloning until end of time
while ( !$vm_info ) {
  start_phase('Cloning VM');
  vm clone => $base_vm => $new_vm;

  my $vm_info;
  eval {
    $vm_info = vm info => $new_vm;
    1;
  };

  &end_phase;
}

#run "/usr/bin/virt-clone --connect qemu:///system -o '$base_vm' -n '$new_vm' --auto-clone -f /ram/$new_vm.img";

start_phase('Starting VM');
my $vm_started = 0;
for (qw/1 2 3/) {
  eval { vm start => $new_vm; $vm_started = 1; };
}
&end_phase;

if ( $vm_started == 0 ) {
  die("Can't start vm: $new_vm.");
}

start_phase('Getting VM info');
my $vminfo = vm guestinfo => $new_vm;
our $ip = $vminfo->{network}->[0]->{ip};
&end_phase;

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
