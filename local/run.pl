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

do "auth.conf";

my $yaml =
  eval { local ( @ARGV, $/ ) = ( $ENV{HOME} . "/.build_config" ); <>; };
$yaml .= "\n";
our $config = Load($yaml);

my $user = $config->{box}->{default}->{user};
my $pass = $config->{box}->{default}->{password};

my $perl_version = $ENV{perl_version};

my $ua = Mojo::UserAgent->new;

my $con_str =
    "http://$config->{jobcontrol}->{user}:$config->{jobcontrol}->{password}\@"
  . "$config->{jobcontrol}->{host}:$config->{jobcontrol}->{port}"
  . "/api/1.0/project/5bde00a59817c6e3e6e79cc4ad8a514a/node";

my $tx = $ua->post(
  $con_str,
  json => {
    name => "rexops-perl-$perl_version-test-$$",
    type => "docker",
    parent =>
      "3a7f1fc9e58a8492fc625d8a16e85e76_c5fd214cdd0d2b3b4272e73b022ba5c2",
    data => {
      image => "rexops-perl-$perl_version:$ENV{docker_tag}",
      host =>
"3a7f1fc9e58a8492fc625d8a16e85e76_1b21b0d71706897b69f108572c444d40_b0da275520918e23dd615e2a747528f1",
      command => "/usr/sbin/sshd -D",
    }
  }
);

my ( $docker_id, $ip );

if ( $tx->success ) {
  my $ref = $tx->res->json;

  $docker_id = $ref->{id};
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

system "REXUSER=$user REXPASS=$pass HTEST=$ip rex -F test";

$ua->delete("$con_str/$docker_id");
