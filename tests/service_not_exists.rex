# vim: set syn=perl:

use Rex -feature => ['0.54'];
#use Rex -feature => ['0.42'];
use Rex::Commands::Service;
use Rex::Commands::Gather;

use Test::More;

do "auth.conf";

desc "Get Hardware Information";
task "test", group => "test", sub {

  my $service = "foononexists";

  my $op = lc(operating_system);

  if($op =~ m/(suse|centos|fedora|redhat|ubuntu|debian|mageia)/) {

    my $ok = 0;
    eval {
      service $service => ensure => "running";
      1;
    } or do {
      $ok = 1;
    };

    ok($ok == 1, "service foononexists not found.");

  }
  else {
    ok(1==1, "no tests for this os");
  }

  done_testing();
};
