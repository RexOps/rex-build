# vim: set syn=perl:
use Rex -feature => '0.45';
use Rex::CMDB;
use Data::Dumper;

use Test::More;

do "auth.conf";

set cmdb => {
  type => "YAML",
  path => "tests.d/cmdb/cmdb",
};

task "test", group => "test", sub {
  my $ntp_server = get cmdb "ntp_server";
  ok($ntp_server->[0] eq "ntp01.test", "got default ntp server");

  Rex::Config->set_environment("stage");
  $ntp_server = get cmdb "ntp_server";
  ok($ntp_server->[0] eq "ntp01.stage", "got stage ntp server");

  Rex::Config->set_environment("live");
  $ntp_server = get cmdb "ntp_server";
  ok($ntp_server->[0] eq "ntp01.live" && $ntp_server->[1] eq "ntp02.live", "got live ntp server");

  done_testing();
};


