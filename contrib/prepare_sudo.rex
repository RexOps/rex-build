# vim: set syn=perl:

use Rex -feature => '1.0';
use Rex::Commands::User;
use YAML;

my $yaml =
  eval { local ( @ARGV, $/ ) = ( $ENV{HOME} . "/.build_config" ); <>; };
$yaml .= "\n";
my $config = Load($yaml);

my $user = $config->{box}->{sudo}->{user};
my $pass = $config->{box}->{sudo}->{password};

if ( exists $ENV{libssh2} ) {
  set connection => 'SSH';
}

user $config->{box}->{default}->{user};
password $config->{box}->{default}->{password};
pass_auth;

group test => $ENV{HTEST};

task prepare => group => test => sub {
  install "sudo";

  create_group $user;

  account $user,
    home        => "/home/$user",
    uid         => 5000,
    groups      => [$user],
    password    => $pass,
    ensure      => "present",
    create_home => TRUE;


  # a user to test sudo -u
  create_group "mytest1";

  account "mytest1",
    home        => "/home/mytest1",
    uid         => 7000,
    groups      => ["mytest1"],
    password    => $pass,
    ensure      => "present",
    create_home => TRUE;

};
