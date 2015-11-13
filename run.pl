#!/usr/bin/env perl

use YAML;
use Data::Dumper;
use Rex -base;
use Rex::Commands::Virtualization;
use Rex::Commands::SimpleCheck;
use Cwd 'getcwd';
use Mojo::UserAgent;

set virtualization => "LibVirt";

our $RETVAL = 0;

my $ua = Mojo::UserAgent->new;
$ua->request_timeout(300);
$ua->inactivity_timeout(300);
$ua->connect_timeout(300);

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
my $time = time;
my $new_vm  = "${base_vm}-test-$time-$$";
$new_vm =~ s/:/_/gms;

#Rex::connect( %{$config} );

&end_phase;

my $vm_info;

start_phase('Creating test VM');

my $con_str =
    "http://$config->{jobcontrol}->{user}:$config->{jobcontrol}->{password}\@"
  . "$config->{jobcontrol}->{host}:$config->{jobcontrol}->{port}"
  . "/api/1.0/project/5bde00a59817c6e3e6e79cc4ad8a514a/node";


our ($vm_id, $ip) = create_vm($new_vm, $base_vm);

&end_phase;

if ( !$ip ) {
  die "Error couldn't get IP address.";
}

start_phase("Waiting for VM SSH port wakeup on $ip");
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

eval {
  do "run.tests.pl";
  1;
} or do {
  $RETVAL = 1;
};

start_phase('Cleaning up VM');

#$ua->delete("$con_str/$vm_id");

remove_vm($vm_id);

#vm destroy => $new_vm;

#vm delete => $new_vm;

#rm "/ram/$new_vm.img";
# fix for #6
#run "virsh vol-delete --pool default $new_vm.img";
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
  printf "%-70s\n", $phase;
}

sub end_phase {
  printf "%4u s\n", scalar( time - $starttime );
}




sub create_vm {

  my ($new_vm, $base_vm) = @_;
  my ($ip, $vm_id);

  if ( $ENV{use_docker} ) {

    my $tx = $ua->post(
      $con_str,
      json => {
        name => $new_vm,
        type => "docker",
        parent => "3a7f1fc9e58a8492fc625d8a16e85e76_c5fd214cdd0d2b3b4272e73b022ba5c2",
        data => {
          image => $base_vm,
          host => "3a7f1fc9e58a8492fc625d8a16e85e76_1b21b0d71706897b69f108572c444d40_b0da275520918e23dd615e2a747528f1",
          command => "/usr/sbin/sshd -D",
        }
      }
    );

    if ( $tx->success ) {
      my $ref = $tx->res->json;

      $vm_id = $ref->{id};
      if ( !$vm_id ) {
        die "Error creating test VM";
      }

      my $qtx = $ua->get("$con_str/$vm_id");
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

  }
  else {

    my $tx = $ua->post(
      $con_str,
      json => {
        name => $new_vm,
        type => "kvm",
        parent => "3a7f1fc9e58a8492fc625d8a16e85e76_c5fd214cdd0d2b3b4272e73b022ba5c2",
        data => {
          image => $base_vm,
          host => "3a7f1fc9e58a8492fc625d8a16e85e76_1b21b0d71706897b69f108572c444d40_b0da275520918e23dd615e2a747528f1",
        }
      }
    );

    if ( $tx->success ) {
      my $ref = $tx->res->json;

      $vm_id = $ref->{id};
      if ( !$vm_id ) {
        die "Error creating test VM";
      }

      my $qtx = $ua->get("$con_str/$vm_id");
      if ( $qtx->success ) {
        my $qref = $qtx->res->json;
        $ip = $qref->{provisioner}->{network}->[0]->{ip};
      }
      else {
        print STDERR Dumper $qtx;
        die "Error getting info of test VM";
      }
    }
    else {
      die "Error creating test VM";
    }

  }

  return ($vm_id, $ip);
}

sub remove_vm {
  my ($vm_id) = @_;
  $ua->delete("$con_str/$vm_id");
}

