#!/usr/bin/env perl

use YAML;
use Data::Dumper;
use Rex -base;
use Rex::Commands::Virtualization;
use Rex::Commands::SimpleCheck;
use Cwd 'getcwd';

set virtualization => "LibVirt";

$::QUIET = 1;

my $yaml =
  eval { local ( @ARGV, $/ ) = ( $ENV{HOME} . "/.build_config" ); <>; };
$yaml .= "\n";
my $config = Load($yaml);

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

Rex::connect( %{$config} );

my $new_vm = "${base_vm}-build-$$";

@SIG{qw( INT TERM HUP )} = sub {
  remove_vm($new_vm);
};

vm clone => $base_vm => $new_vm;

vm start => $new_vm;

my $vminfo = vm guestinfo => $new_vm;
my $ip = $vminfo->{network}->[0]->{ip};

while ( !is_port_open( $ip, 22 ) ) {
  sleep 1;
}

my ( $user, $pass );

$user = $config->{box}->{default}->{user};
$pass = $config->{box}->{default}->{password};

print "Running: REXUSER=$user REXPASS=$pass HTEST=$ip rex -f build/Rexfile "
  . "-c bundle --build=$build_file "
  . "--branch=$branch --environment=$environment --repo=$ENV{BUILD_REPO}\n";

system "REXUSER=$user REXPASS=$pass HTEST=$ip rex -f build/Rexfile "
  . "-c bundle --build=$build_file "
  . "--branch=$branch --environment=$environment --repo=$ENV{BUILD_REPO}";

my $exit_code = $?;

remove_vm($new_vm);

exit $exit_code;

sub remove_vm {
  my ($name) = @_;

  vm destroy => $name;

  vm delete => $name;

  #rm "/var/lib/libvirt/images/$new_vm.img";
  # fix for #6
  run "virsh vol-delete --pool default $name.img";
}
