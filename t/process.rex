use Rex -feature => '0.42';
use Data::Dumper;
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
   my ($sshd1) = grep { $_->{"command"} && $_->{"command"} =~ m/sshd \-p 9999/ } ps();
   print ($sshd1->{"pid"});
   kill $sshd1->{"pid"}, 9;
   ($sshd1) = grep { $_->{"command"} && $_->{"command"} =~ m/sshd \-p 9999/ } ps();
   ok( ! $sshd1, "process was killed." );

##killall($name, $sig)
#   my ($crond) = grep { $_->{"command"} && $_->{"command"} =~ m/crond/ } ps();
#   killall $crond->{"pid"}, 9;
#   ($crond) = grep { $_->{"command"} && $_->{"command"} =~ m/crond/ } ps();
#   ok( ! $crond, "process was killed via killall" );

#nice($pid, $level)

   run "/usr/sbin/sshd -p 9998";
   my $nice = 19;
   my ($sshd2) = grep { $_->{"command"} && $_->{"command"} =~ m/sshd -p 9998/ } ps();
   my ($sshpid) = $sshd2->{"pid"};
   nice $sshpid, $nice;
   run "ps -p  $sshpid -o priority=", sub {
       my ($stdout, $stderr) = @_;
       ok( $stdout = $nice, "niceness set successfully" );
    };

   done_testing();
};

