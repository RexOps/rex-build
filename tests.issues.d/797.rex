# vim: set syn=perl:
use Test::More;

use Rex::Commands::Run;
use Rex::Helper::Path;
use Rex::Commands::Pkg;
use Rex::Commands::SCM;
use Rex::Commands::Fs;

do 'auth.conf';

set repository => "myrepo",
  url => 'git://github.com/RexOps/Rex.git';

task test => group => test => sub {
  
  my $test_dir = "/tmp/git-test-$$";
  
  if(is_redhat() && operating_system_release() =~ m/^5\./) {
    ok(1==1, "No test for Centos 5");
    done_testing();
    return;
  }

  pkg "git";
  
  checkout "myrepo", path => $test_dir;
  is(is_dir($test_dir), 1, "checkout path exists");
  is(is_dir("$test_dir/lib"), 1, "checkout successfull");
  
  my $branch = run "git status |  grep -i 'on branch'", cwd => $test_dir;
  chomp $branch;
  ok($branch =~ m/development/, "got master(development) branch");
  
  run "rm -rf $test_dir";
  
  checkout "myrepo", path => $test_dir, branch => "only_a_test_branch";
  my $branch = run "git status |  grep -i 'on branch'", cwd => $test_dir;
  chomp $branch;
  ok($branch =~ m/only_a_test_branch/, "got only_a_test_branch branch");

  run "rm -rf $test_dir";

  $::QUIET = 1; # suppress expected warning for checking out a non-existing branch

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
