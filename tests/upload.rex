# vim: set syn=perl:

use Rex -feature => '0.42';
use Test::More;

do "auth.conf";

task test => group => test => sub {

   LOCAL {
      download "http://rex.linux-files.org/test/file.bin";
   };

   my $orig_md5 = "991ceda993d8f8f98191e461d7d8cd76";

   LOCAL {
      ok($orig_md5 eq md5("file.bin"), "downloaded local md5 matches");
   };

   upload "file.bin", "/root";

   ok(is_file("/root/file.bin"), "upload okay");

   ok($orig_md5 eq md5("/root/file.bin"), "uploaded md5 okay");

   done_testing();
};

