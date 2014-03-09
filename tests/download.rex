# vim: set syn=perl:
use Rex -feature => '0.42';

use Rex::Commands::MD5;
use Data::Dumper;
use Test::More;

do "auth.conf";

task "test", group => "test", sub {

  my $remote_md5 = md5('/etc/passwd');

  download "/etc/passwd", "./passwd.test";

  LOCAL {
    ok(is_file("passwd.test"), "download okay");
    ok($remote_md5 eq md5("passwd.test"), "local md5 okay");

    rm "passwd.test";

    ok(! is_file("passwd.test"), "delete okay");
  };

  download "/etc/passwd", "./passwd.test";

  done_testing();
};

