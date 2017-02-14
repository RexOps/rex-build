#!/usr/bin/env perl

use YAML;
use Data::Dumper;
use Rex -base;
use Rex::Commands::Virtualization;
use Rex::Commands::SimpleCheck;
use Cwd 'getcwd';
use Mojo::UserAgent;

$::QUIET = 1;
$|       = 1;

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

my $time   = time;
my $new_vm = "${base_vm}-build-$time-$$";

@SIG{qw( INT TERM HUP )} = sub {
  remove_amazon($new_vm);
};

say "Creating VM...";
my ( $vm_id, $ip ) = start_amazon( $new_vm, $base_vm );

say $vm_id;
say $ip;

say "Waiting for SSH port to be open...";

my $count;
while ( !is_port_open( $ip, 22 ) ) {
  die "Timed out waiting for SSH" if ++$count > 300;
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

remove_amazon($vm_id);

exit $exit_code;

sub start_amazon {
  # wait to not run into rate limit
  #sleep (int(rand(10)) + 10);
  my ($name, $image_id) = @_;

  my $image_id = shift;
  my $vm = cloud_instance create => {
    image_id       => $image_id,
    name           => $name,
    key            => "integration-tests",
    type           => $instance_type,
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

