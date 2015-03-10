# vim: set syn=perl:
use Test::More;

do "auth.conf";

task test => group => test => sub {
  # create a symlink
  symlink "/etc", "/tmp/foo";
  is(readlink("/tmp/foo"), "/etc", "/tmp/foo is a link to /etc");

  symlink "/usr", "/tmp/foo";
  is(readlink("/tmp/foo"), "/usr", "/tmp/foo is a link to /usr");

  done_testing();
};

1;
