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
$ua->request_timeout(300);
$ua->inactivity_timeout(300);

$::QUIET = 1;

my $yaml = eval { local(@ARGV, $/) = ($ENV{HOME} . "/.build_config"); <>; };
$yaml .= "\n";
my $config = Load($yaml);

my $con_str =
    "http://$config->{jobcontrol}->{user}:$config->{jobcontrol}->{password}\@"
  . "$config->{jobcontrol}->{host}:$config->{jobcontrol}->{port}"
  . "/api/1.0/project/5bde00a59817c6e3e6e79cc4ad8a514a/node";

my $base_vm = $ARGV[0];

my $time = time;
my $new_vm = "${base_vm}-install-test-$time-$$";

my ($vm_id, $ip) = create_vm($new_vm, $base_vm);

while(! is_port_open($ip, 22)) {
  sleep 1;
}

my ($user, $pass);

$user = $config->{box}->{default}->{user};
$pass = $config->{box}->{default}->{password};

# run tests from tests directory
$ENV{PATH} = getcwd() . ":" . $ENV{PATH};
system "REXUSER=$user REXPASS=$pass HTEST=$ip prove --timer --formatter TAP::Formatter::JUnit --ext rex -e rex-test t >../junit_output_tests.xml";


remove_vm($vm_id);



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
