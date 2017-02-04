# vim: set syn=perl:
use Test::More;

do 'auth.conf';

desc "real_test";
task "real_test", sub {
  file "/tmp/test-1132", ensure => "directory";
  file "/tmp/test-1132/test.txt", content => "blub\n";

  my $user = "rsync_user";
  my $outputs;
  sudo {
    user => $user,
    command => sub {
      $outputs = run "export",
        cwd => "/tmp/test-1132",
        command => "ls";
      chomp $outputs;
    }
  };

  return $outputs;

};

task test => group => test => sub {
  my $out = real_test();
  is($out, "test.txt", "issue 1132 fixed");
  done_testing();
};


1;