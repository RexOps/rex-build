use Rex -feature => '0.42';

use Rex::Commands::MD5;
use Data::Dumper;
use Test::More;

user $ENV{REXUSER};
password $ENV{REXPASS};
pass_auth;

if(exists $ENV{use_sudo}) {
   sudo_password $ENV{REXPASS};
   sudo -on;
}

group test => $ENV{HTEST};

task "test", group => "test", sub {

   my ($calc_md5);

   my $orig_md5 = "991ceda993d8f8f98191e461d7d8cd76";

   download "/root/file.bin", ".";

   LOCAL {
      ok(is_file("file.bin"), "download okay");
      ok($orig_md5 eq md5("file.bin"), "local md5 okay");

      rm "file.bin";

      ok(! is_file("file.bin"), "delete okay");
   };

   rm "/root/file.bin";
   ok(! is_file("/root/file.bin"), "remote delete okay");

   done_testing();
};

