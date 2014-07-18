# vim: set syn=perl:
use Rex -feature => '0.42';

use Rex::Commands::MD5;
use Data::Dumper;
use Test::More;

do "auth.conf";

task "test", group => "test", sub {

  my $remote_md5 = md5('/etc/passwd');

  my $s = connection->server;
  download "/etc/passwd", "./passwd.test.$s";

  LOCAL {
    ok(is_file("passwd.test.$s"), "download okay");
    ok($remote_md5 eq md5("passwd.test.$s"), "local md5 okay");

    rm "passwd.test.$s";

    ok(! is_file("passwd.test.$s"), "delete okay");
  };

  done_testing();
};
