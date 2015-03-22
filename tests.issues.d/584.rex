# vim: set syn=perl:
use Test::Tester;
use Test::More;
use Rex::Test::Base;

do "auth.conf";

task test => group => test => sub {

  my $test = Rex::Test::Base->new;

  {
    local $Test::Builder::Level = 2;
    check_test(
      sub {
        $test->has_dir("/etc");
      },
      {
        ok => 1,
        name => "Found /etc directory.",
      },
      "has_dir with existing directory",
    );

    check_test(
      sub {
        $test->has_dir("/etc2");
      },
      {
        ok => 0,   # expect to fail
        name => "Found /etc2 directory.",
      },
      "has_dir with non existing directory",
    );

    check_test(
      sub {
        $test->has_file("/etc/passwd");
      },
      {
        ok => 1,
        name => "Found /etc/passwd file.",
      },
      "has_file with existing file",
    );

    check_test(
      sub {
        $test->has_file("/etc/nono");
      },
      {
        ok => 0,   # expect to fail
        name => "Found /etc/nono file.",
      },
      "has_file with non existing file",
    );

  }

  #is($test->has_dir("/etc2"), 0, "directory not found.");

  done_testing();
};

1;
