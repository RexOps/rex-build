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
   my $packages = case operating_system, {
                     qr{centos|redhat}i  => [qw/perl openssh-clients perl-Data-Dumper/],
                     default             => [qw/perl/],
                  };
   eval {
      install $packages;
   };
};

