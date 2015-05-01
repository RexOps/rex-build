# vim: set syn=perl:

use Rex -feature => '0.42';
use Test::More;

do "auth.conf";

task test => group => test => sub {

  my @files = grep {  is_file(Rex::Config->get_tmp_dir . "/$_") } grep { m/\.tmp$/ } list_files(Rex::Config->get_tmp_dir);
  ok(scalar(@files) == 0, "tmp_dir is empty");

  for my $file (@files) {
    print STDERR "========= $file ========\n";
    print STDERR cat(Rex::Config->get_tmp_dir . "/$file");
  }

  done_testing();
};

