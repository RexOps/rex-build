use Rex -feature => '0.42';
use Test::More;
use Rex::Commands::Fs;

user $ENV{REXUSER};
password $ENV{REXPASS};
pass_auth;

if(exists $ENV{use_sudo}) {
   sudo_password $ENV{REXPASS};
   sudo -on;
}

group test => $ENV{HTEST};

task test => group => test => sub {

   ok(is_file("/etc/passwd"), "is_file: /etc/passwd is a file");
   ok(is_dir("/etc"), "is_dir: /etc is a directory");
   ok(is_readable("/etc"), "is_readable: /etc is_readable");
   ok(is_writable("/tmp"), "is_writable: /tmp is_writable");

   my @etc = grep { /^passwd$/ } list_files("/etc");
   ok(scalar(@etc) == 1, "list_files: found passwd");

   symlink("/etc/passwd", "/tmp/passwd");
   ok(readlink("/tmp/passwd") eq "/etc/passwd", "readlink, symlink: ok");

   unlink("/tmp/passwd");
   ok(!is_file("/tmp/passwd"), "unlink: /tmp/passwd is removed");

   eval {
      readlink "/tmp/passwd";
      print "failed\n";
   };
   ok($@, "readlink on no link");

   mkdir "/tmp/t";
   ok(is_dir("/tmp/t"), "mkdir: dir created");

   mkdir "/tmp/t/bla/blub/ha/do/jo/mo/klo";
   ok(is_dir("/tmp/t/bla/blub/ha/do/jo/mo/klo"), "mkdir: recursive ok");

   rmdir "/tmp/t";
   ok(!is_dir("/tmp/t"), "rmdir: dir removed");

   mkdir "/tmp/ug",
            owner => "nobody",
            group => "nobody",
            mode  => 700;

   ok(is_dir("/tmp/ug"), "mkdir w/ options created dir");
   my %stat = stat("/tmp/ug");
   ok($stat{"mode"} == 700, "mkdir w/ options: mode 700");

   file "/tmp/chmod.test", content => "foo";
   chmod 701, "/tmp/chmod.test";
   my %stat2 = stat("/tmp/chmod.test");
   ok($stat2{"mode"} == 701, "chmod: testfile has chmod 701");

   eval {
      mkdir "/tmp/l/u/o/p",
         not_recursive => 1;
   };

   ok(!is_dir("/tmp/l/u/o/p"), "mkdir: non-recursive");

   run "rm -rf /tmp/l";

   eval {
      mkdir "tmp";
   };

   ok(is_dir("tmp"), "mkdir: relative dir");

   rename "/tmp/chmod.test", "/tmp/rename.test";
   ok(is_file("/tmp/rename.test"), "rename: chmod.test to rename.test");

   ok(!is_file("/tmp/copy.test"), "copy.test not there yet");
   cp "/tmp/rename.test", "/tmp/copy.test";
   ok(is_file("/tmp/copy.test"), "cp: copy.test exists");

   #unlink "/tmp/rename.test";
   #unlink "/tmp/copy.test";
   #ok(! is_file("/tmp/rename.test"), "removed rename.test");
   #ok(! is_file("/tmp/copy.test"), "removed copy.test");

   #if(is_linux) {
   #   my $df = df "/dev/sda1";
   #   ok($df->{free} >= 1000, "got df free from /dev/sda1");
   #   ok($df->{used} >= 1000, "got df used from /dev/sda1");
   #   ok($df->{mounted_on}, "got df mounted on from /dev/sda1");

   #};
   done_testing();
};
