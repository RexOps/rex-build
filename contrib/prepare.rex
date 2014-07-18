# vim: set syn=perl:

use Rex -feature => '0.42';
use Rex::Commands::User;
use Rex::Hardware::Network;
use List::Util qw/first/;
use YAML;

my $yaml =
  eval { local ( @ARGV, $/ ) = ( $ENV{HOME} . "/.build_config" ); <>; };
$yaml .= "\n";
my $config = Load($yaml);

my $user = $config->{box}->{sudo}->{user};
my $pass = $config->{box}->{sudo}->{password};

user( $ENV{REX_USER}     || $config->{box}->{default}->{user} );
password( $ENV{REX_PASS} || $config->{box}->{default}->{password} );
pass_auth;

group test => split(/ /, $ENV{HTEST});

parallelism 50;

task prepare => group => test => sub {

  # images are absolute minimal

  eval {    # just update the package db, if it fails it doesn't matter
    update_package_db;
  };

  my @packages = qw/perl rsync/;

  my $additional_packages = case operating_system, {
    qr{centos|redhat}i => [qw/openssh-clients dmidecode/],
      qr{freebsd}i     => [qw/dmidecode/],
      qr{openwrt}i     => [
      qw/coreutils-nohup perlbase-bytes perlbase-digest perlbase-essential perlbase-file perlbase-xsloader shadow-groupadd shadow-groupdel shadow-groupmod shadow-useradd shadow-userdel shadow-usermod swap-utils/
      ],
      qr{debian|ubuntu}i => [qw/rsync/],
      qr{suse}i          => [qw/lsb-release/],
      qr{fedora}i        => [qw/perl openssh-clients which/],
      default            => [],
  };

  if ( is_freebsd && operating_system_release >= 10 ) {
    @packages = qw/perl5 rsync/;
  }

  if ( is_redhat && operating_system_release >= 7 ) {
    push @packages, "net-tools";
  }

  push @packages, @{$additional_packages};

  eval { install \@packages; };

  eval {
    # ensure that /home exists
    mkdir "/home";

    # some tests need this group
    create_group "nobody";

    # some tests need a user
    account "nobody", groups => ["nobody"], ensure => "present";

    create_group "rsync_user",
      gid => 6000,
      ;

    account "rsync_user",
      ensure      => "present",
      uid         => 6000,
      password    => "rsync.pw",
      home        => "/home/rsync_user",
      create_home => TRUE,
      groups      => ["rsync_user"];

    if ( is_openwrt() ) {
      account "rsync_user", ensure => "present", shell => "/bin/ash";
    }

  };

  run "echo 127.0.2.1 `uname -n` >>/etc/hosts";

  file "/root/.profile", content => "export MYFOO='MYBAR'\nexport PATH=/bin\n";

  # for csh
  file "/root/.login", content => "set MYFOO='MYBAR'\nset PATH=/bin\n";

  mkdir "/tmp2";

  # create a swap file
  run "dd if=/dev/zero of=/swap.img bs=16000 count=1k";
  if ( $? == 0 ) {
    run "mkswap /swap.img ; chmod 600 /swap.img";
    run "swapon /swap.img";
  }

  my $net = Rex::Hardware::Network->get;

  my @devs = @{ $net->{networkdevices} };
  my $dev = first { $_ =~ m/(eth0|em0|e1000g0)/ } @{ $net->{networkdevices} };

  Rex::Logger::info("Creating alias: $dev:1");

  # create alias eth device
  if (is_freebsd) {
    run "ifconfig $dev 1.2.3.4 netmask 255.255.255.255 alias";
  }
  else {
    run "ifconfig $dev:1 1.2.3.4 netmask 255.255.255.255";
    if ( $? != 0 ) {
      run "ip addr add 1.2.3.4/32 dev $dev label $dev:1";
    }
  }
};
