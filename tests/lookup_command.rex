# vim: set syn=perl:
use Rex -feature => '0.42';

use Rex::Commands::MD5;
use Data::Dumper;
use Test::More;
use Rex::Group::Lookup::Command;

do "auth.conf";

task "test", group => "test", sub {

  LOCAL {
    file "ip.lst.$$",
      content => "1.2.3.4\n4.3.2.1\n2.3.2.1\n";

    my @server_lst = lookup_command "cat ip.lst.$$";

    ok(scalar(@server_lst) == 3, "got 3 elements");
    ok($server_lst[0] eq "1.2.3.4", "got first entry");
    ok($server_lst[1] eq "4.3.2.1", "got second entry");
    ok($server_lst[2] eq "2.3.2.1", "got third entry");

    rm "ip.lst.$$";
  };

  done_testing();
};

