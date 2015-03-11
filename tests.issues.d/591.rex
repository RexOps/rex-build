# vim: set syn=perl:
use Test::More;

do "auth.conf";

task test => group => test => sub {
  # create a symlink
  symlink "/etc", "/tmp/issue591";
  is(readlink("/tmp/issue591"), "/etc", "/tmp/issue591 is a link to /etc");

  symlink "/usr", "/tmp/issue591";
  is(readlink("/tmp/issue591"), "/usr", "/tmp/issue591 is a link to /usr");

  unlink "/tmp/issue591";
  ok(!is_symlink("/tmp/issue591"), "/tmp/issue591 is removed");

  done_testing();
};

1;
