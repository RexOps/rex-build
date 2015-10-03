# vim: set syn=perl:
use Test::More;

use Rex::Commands::Run;
use Rex::Helper::Path;
use Rex::Commands::Pkg;
use Rex::Commands::SCM;

do 'auth.conf';

set repository => "myrepo",
  url => 'https://github.com/RexOps/Rex.git';

task test => group => test => sub {
  
  my $test_dir = "/tmp/git-test-$$";
  pkg "git";
  
  checkout "myrepo", path => $test_dir;
  is(-d $test_dir, 1, "checkout path exists");
  is(-d "$test_dir/lib", 1, "checkout successfull");
  
  my $branch = run "git status |  grep -i 'on branch' | awk ' { print \$3 } '", cwd => $test_dir;
  chomp $branch;
  is($branch, "master", "got master branch");
  
  run "rm -rf $test_dir";
  
  checkout "myrepo", path => $test_dir, branch => "2.0";
  my $branch = run "git status |  grep -i 'on branch' | awk ' { print \$3 } '", cwd => $test_dir;
  chomp $branch;
  is($branch, "2.0", "got 2.0 branch");

  run "rm -rf $test_dir";

  eval {
    checkout "myrepo", path => $test_dir, branch => "doesnt-exists";
    ok(1==2, "checkout of unknown branch successfull.");
    1;
  } or do {
    ok(1==1, "checkout of unknown branch failed.");
  };
  
  done_testing();
};

1;
