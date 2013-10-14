# vim: set syn=perl:

use Rex -feature => '0.42';
use Rex::Commands::User;
use YAML;

my $yaml = eval { local(@ARGV, $/) = ($ENV{HOME} . "/.build_config"); <>; };
$yaml .= "\n";
my $config = Load($yaml);

my $user = $config->{box}->{sudo}->{user};
my $pass = $config->{box}->{sudo}->{password};

user $config->{box}->{default}->{user};
password $config->{box}->{default}->{password};
pass_auth;

group test => $ENV{HTEST};

task prepare => group => test => sub {
   # images are absolute minimal

   update_package_db if is_openwrt;

   my $packages = case operating_system, {
                     qr{centos|redhat}i  => [qw/perl openssh-clients perl-Data-Dumper rsync/],
                     default             => [qw/perl rsync/],
                     qr{freebsd}i        => [qw/perl rsync dmidecode/],
                     qr{openwrt}i        => [qw/perl rsync perlbase-bytes perlbase-data perlbase-digest perlbase-essential perlbase-xsloader/],
                  };
   eval {
      for my $pkg (@{ $packages }) {
         install $pkg;
      }
   };

   eval {
      # some tests need this group
      create_group "nobody";

      # some tests need a user
      create_user "nobody",
         groups => ["nobody"];
   };

   run "echo 127.0.2.1 `hostname` >>/etc/hosts";

   mkdir "/tmp2";
};

