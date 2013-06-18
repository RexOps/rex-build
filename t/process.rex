use Rex -feature => '0.42';
use Test::More;

user $ENV{REXUSER};
password $ENV{REXPASS};
pass_auth;

if(exists $ENV{use_sudo}) {
   sudo_password $ENV{REXPASS};
   sudo -on;
}

group test => $ENV{HTEST};

task test => group => test => sub {

  run "/usr/sbin/sshd -p 9999";

#ps
   my @list = grep { $_->{"pid"} eq "1" } ps();
   ok($list[0]->{"command"} =~ m/init|systemd/, "ps, found init command");

#kill($pid, $sig)
   my ($sshd) = grep { $_->{"command"} && $_->{"command"} =~ m/sshd -p 9999/ } ps();
   kill $sshd->{"pid"};
   ($sshd) = grep { $_->{"command"} && $_->{"command"} =~ m/sshd -p 9999/ } ps();
   ok( ! $sshd, "process was killed." );

#killall($name, $sig)
   

#nice($pid, $level)

   run "/usr/sbin/sshd -p 9998";
   my $nice = 19;
   my ($sshd) = grep { $_->{"command"} && $_->{"command"} =~ m/sshd -p 9998/ } ps();
   my ($sshpid) = $sshd->{"pid"};
   nice $sshpid, $nice;
   run "ps -p  $sshpid -o priority=", sub {
       my ($stdout, $stderr) = @_;
       ok( $stdout = $nice, "niceness set successfully");
    };

   done_testing();
};

