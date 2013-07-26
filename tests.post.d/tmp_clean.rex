# vim: set syn=perl:

use Rex -feature => '0.42';
use Test::More;

do "auth.conf";

task test => group => test => sub {

   my @files = list_files(Rex::Config->get_tmp_dir);
   ok(scalar(@files) == 0, "tmp_dir is empty");

   done_testing();
};

