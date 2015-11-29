#!/usr/bin/env perl

use YAML;
use Data::Dumper;
use Rex -base;
use Rex::Commands::Virtualization;
use Rex::Commands::SimpleCheck;
use Cwd 'getcwd';
use Mojo::UserAgent;

my $ua = Mojo::UserAgent->new;
$ua->request_timeout(360);
$ua->inactivity_timeout(360);

$::QUIET = 1;
$|       = 1;

my $yaml =
  eval { local ( @ARGV, $/ ) = ( $ENV{HOME} . "/.build_config" ); <>; };
$yaml .= "\n";
my $config = Load($yaml);

my $con_str =
    "http://$config->{jobcontrol}->{user}:$config->{jobcontrol}->{password}\@"
  . "$config->{jobcontrol}->{host}:$config->{jobcontrol}->{port}"
  . "/api/1.0/project/5bde00a59817c6e3e6e79cc4ad8a514a/node";

chdir "..";

my $base_vm    = $ARGV[0];
my $build_file = $ARGV[1];

if ( !$base_vm ) {
  die("No base vm given");
}

if ( !$build_file || !-f $build_file ) {
  die("No (valid) build file given");
}

my $branch      = $ENV{REX_BRANCH} || 'master';
my $environment = $ENV{BUILD_ENV}  || 'nightly';

my $time   = time;
my $new_vm = "${base_vm}-build-$time-$$";

@SIG{qw( INT TERM HUP )} = sub {
  remove_vm($new_vm);
};

say "Creating VM...";
my ( $vm_id, $ip ) = create_vm( $new_vm, $base_vm );

say $vm_id;
say $ip;

say "Waiting for SSH port to be open...";

my $count;
while ( !is_port_open( $ip, 22 ) ) {
  die "Timed out waiting for SSH" if ++$count > 60;
  sleep 1;
}

say "SSH port is open";

my ( $user, $pass );

$user = $config->{box}->{default}->{user};
$pass = $config->{box}->{default}->{password};

print "Running: REXUSER=$user REXPASS=$pass HTEST=$ip rex -f build/Rexfile "
  . "-c bundle --build=$build_file "
  . "--branch=$branch --environment=$environment --repo=$ENV{BUILD_REPO}\n";

$ENV{rex_opts} ||= "";

system "REXUSER=$user REXPASS=$pass HTEST=$ip rex $ENV{rex_opts} -f build/Rexfile "
  . "-c bundle --build=$build_file "
  . "--branch=$branch --environment=$environment --repo=$ENV{BUILD_REPO}";

my $exit_code = $?;

remove_vm($vm_id);

exit $exit_code;

sub create_vm {

  my ( $new_vm, $base_vm ) = @_;
  my ( $ip, $vm_id );

  if ( $ENV{use_docker} ) {

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
        parent =>
          "3a7f1fc9e58a8492fc625d8a16e85e76_c5fd214cdd0d2b3b4272e73b022ba5c2",
        data => {
          image => $base_vm,
          host =>
"3a7f1fc9e58a8492fc625d8a16e85e76_1b21b0d71706897b69f108572c444d40_b0da275520918e23dd615e2a747528f1",
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

  return ( $vm_id, $ip );
}

sub remove_vm {
  my ($vm_id) = @_;
  $ua->delete("$con_str/$vm_id");
}
