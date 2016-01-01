# vim: set syn=perl:

use Rex -feature => '1.0';
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

if ( exists $ENV{libssh2} ) {
  set connection => 'SSH';
}

user( $config->{box}->{default}->{user} );
password( $config->{box}->{default}->{password} );
pass_auth;

group test => split( / /, $ENV{HTEST} );

parallelism 50;

task prepare => group => test => sub {

  # images are absolute minimal
  if (is_freebsd) {
    if(operating_system_release =~ m/^8\./) {
      file "/usr/local/etc/pkg/repos",
        ensure => "directory",
        owner  => "root",
        group  => "wheel",
        mode   => 755;

      file "/usr/local/etc/pkg/repos/FreeBSD.conf",
        ensure => "present",
        source => "files/freebsd/FreeBSD.conf",
        owner  => "root",
        group  => "wheel",
        mode   => 644;

      file "/usr/local/etc/pkg.conf",
        ensure => "present",
        source => "files/freebsd/pkg.conf",
        owner  => "root",
        group  => "wheel",
        mode   => 644;
    }

    run "pwd_mkdb /etc/master.passwd";
  }

  eval {    # just update the package db, if it fails it doesn't matter
    update_package_db;
  };

  my @packages = qw/perl rsync sudo/;

  my $additional_packages = case operating_system, {
    qr{centos|redhat}i => [qw/perl-Digest-MD5 openssh-clients dmidecode augeas augeas-libs/],
      qr{freebsd}i     => [qw/dmidecode rsync sudo/],
      qr{openwrt}i     => [
      qw/block-mount coreutils-nohup perlbase-bytes perlbase-digest perlbase-essential perlbase-file perlbase-xsloader shadow-groupadd shadow-groupdel shadow-groupmod shadow-useradd shadow-userdel shadow-usermod swap-utils/
      ],
      qr{debian|ubuntu}i => [qw/rsync augeas-tools augeas-lenses iptables/],
      qr{suse}i          => [qw/lsb-release augeas augeas-lenses/],
      qr{fedora}i        => [qw/perl perl-Digest-MD5 openssh-clients which augeas augeas-libs/],
      qr{gentoo}i        => [ 'sys-process/vixie-cron', 'app-admin/augeas' ],
      default            => [],
  };

  if ( is_freebsd && operating_system_release >= 10 ) {
    @packages = qw/perl5 rsync/;
  }

  if ( is_redhat && operating_system_release >= 7 ) {
    push @packages, "net-tools";
  }

  push @packages, @{$additional_packages};

  for my $p (@packages) {
    eval {
      pkg $p, ensure => "present";
    };
  }

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

  file "/root/.profile",
    content => "export MYFOO='MYBAR'\nexport PATH=/usr/local/bin:/bin:/usr/bin\n";

  # for csh
  file "/root/.login", content => "set MYFOO='MYBAR'\nset PATH=/usr/local/bin:/bin:/usr/bin\n";

  mkdir "/tmp2";

  # create a swap file
  run "dd if=/dev/zero of=/swap.img bs=16000 count=1k";
  if ( $? == 0 ) {
    run "mkswap /swap.img ; chmod 600 /swap.img";
    run "swapon /swap.img";
  }

  my $net = Rex::Hardware::Network->get;

  my @devs = @{ $net->{networkdevices} };
  my $dev = first { $_ =~ m/(eth0|em0|e1000g0|enp0s3)/ } @{ $net->{networkdevices} };

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

  {    # for issue: 473
    if ( $ENV{use_sudo} ) {
      file "/root/issue473.txt",
        owner   => "root",
        group   => "root",
        content => "issue473",
        mode    => 600;

      chmod 700, "/root";
    }
  }

  {    # for issue: 498
    mkdir "/tmp/issue498";
  }

  # need to set_home / always_set_home so that sudo find the right home directory
  # this is done in prepare.rex and not in prepare_sudo.rex for issue #788
  my $sudoers_file = "/etc/sudoers";
  if(is_freebsd) {
    $sudoers_file = "/usr/local/etc/sudoers";
  }

  file $sudoers_file,
    content =>
    "Defaults set_home, always_set_home\n\%$user	ALL=(ALL:ALL) ALL\nrsync_user	ALL=(ALL:ALL) ALL\nrsync_user ALL=(ALL:ALL) NOPASSWD: /usr/bin/rsync\nrsync_user ALL=(ALL:ALL) NOPASSWD: /usr/local/bin/rsync\ntestu ALL=(ALL:ALL) ALL\n",
    owner => "root",
    mode  => 440;


};
