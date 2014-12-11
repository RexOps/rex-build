# vim: set syn=perl:
use Rex -feature => 0.42;
use Rex::Commands::Rsync;
use Test::More;
use Rex::Commands::Gather;

do "auth.conf";

timeout 15;

task "test", group => "test", sub {

  my $out = sudo {
    command => "whoami",
    user    => "mytest1",
  };

  ok($out eq "mytest1", "got mytest1 user");

  file "/tmp/sudouser.txt", content => "sudouser test";
  my %stat = stat "/tmp/sudouser.txt";
  ok($stat{uid} == 5000, "/tmp/sudouser.txt owner");

  sudo {
    command => sub {
      file "/tmp/mytest1.txt", content => "mytest1 test", mode => '755';
    },
    user    => "mytest1",
  };

  %stat = stat "/tmp/mytest1.txt";
  ok($stat{uid} == 7000, "/tmp/mytest1.txt owner");
  ok($stat{mode} == 755, "/tmp/mytest1.txt mode");


  done_testing();
};


