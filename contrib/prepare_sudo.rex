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
   my $yaml = eval { local(@ARGV, $/) = ($ENV{HOME} . "/.build_config"); <>; };
   $yaml .= "\n";
   my $config = Load($yaml);

   install "sudo";

   create_group $user;

   create_user $user,
      home     => "/home/$user",
      groups   => [$user],
      password => $pass;

   file "/etc/sudoers",
      content => "\%$user	ALL=(ALL:ALL) ALL\n",
      owner   => "root",
      mode    => 400;
};

