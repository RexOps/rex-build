# vim: set syn=perl:

use Rex -feature => '0.42';
use Rex::Commands::File;
use Rex::Commands::Fs;
use Rex::Commands::User;
use Test::More;

user $ENV{REXUSER};
password $ENV{REXPASS};
pass_auth;

if(exists $ENV{use_sudo}) {
   sudo_password $ENV{REXPASS};
   sudo -on;
}

if(exists $ENV{openssh}) {
   set connection => 'OpenSSH';
}

group test => $ENV{HTEST};



desc "test";
task "test", group => "test", sub {

   my $uid = get_uid "nobody";
   my $gid = get_gid "nobody";

   file "/tmp/file with space.txt",
      content => "file with space\nin it\n",
      owner   => "root",
      mode    => 644;

   ok(is_file("/tmp/file with space.txt"), "file with space.txt exists");

   my $c = cat "/tmp/file with space.txt";
   ok($c =~ m/file with space/m, "file with space - got content");


   my %stat = stat "/tmp/file with space.txt";
   ok($stat{uid} == 0, "file owner is root");
   ok($stat{mode} == 644, "file mode is 644");
   chown "nobody", "/tmp/file with space.txt";
   chmod 700, "/tmp/file with space.txt";
   %stat = ();
   %stat = stat "/tmp/file with space.txt";
   ok($stat{uid} != 0, "file owner is not root");
   ok($stat{mode} == 700, "file mode is 700");

   unlink "/tmp/file with space.txt";

   ok(! is_file("/tmp/file with space.txt"), "file with space.txt removed");

   ln "/etc/passwd", "/tmp/foo.passwd";
   ok(readlink("/tmp/foo.passwd") eq "/etc/passwd", "ln and readlink works");
   unlink "/tmp/foo.passwd";

   mkdir "/tmp/foo.dir";
   ok(is_dir("/tmp/foo.dir"), "/tmp/foo.dir is a directory");
   rmdir "/tmp/foo.dir";
   ok(! is_dir("/tmp/foo.dir"), "/tmp/foo.dir doesnt exists");

   mkdir "/tmp/foo dir";
   ok(is_dir("/tmp/foo dir"), "/tmp/foo dir is a directory");

   file "/tmp/foo dir/blah.txt",
      content => "BLAH\n";

   $c = cat "/tmp/foo dir/blah.txt";
   ok($c =~ m/BLAH/, "file() - dir with space");
   $c = "";

   file "/tmp/foo dir/blah with space.txt",
      content => "blah with space\n";
   $c = cat "/tmp/foo dir/blah with space.txt";
   ok($c =~ m/blah with space/, "file() - dir and file with space");
   $c = "";

   file "/tmp/foo dir/blah with space2.txt",
      content => "this is test\n";
   $c = cat "/tmp/foo dir/blah with space2.txt";
   ok($c =~ m/this is test/, "file() - dir and file with space (2)");
   $c = "";


   mkdir "/tmp/blah-copy";
   cp "/tmp/foo dir/*", "/tmp/blah-copy";

   ok(is_file("/tmp/blah-copy/blah.txt"), "is_file() - blah.txt (blah-copy)");
   $c = cat "/tmp/blah-copy/blah.txt";
   ok($c =~ m/BLAH/, "file() - dir with space (blah-copy)");
   $c = "";

   ok(is_file("/tmp/blah-copy/blah with space.txt"), "is_file() - blah with space.txt (blah-copy)");
   $c = cat "/tmp/blah-copy/blah with space.txt";
   ok($c =~ m/blah with space/, "file() - dir and file with space (blah-copy)");
   $c = "";

   chown "nobody", "/tmp/blah-copy/blah with space.txt";
   %stat = ();
   %stat = stat "/tmp/blah-copy/blah with space.txt";
   ok($stat{uid} == $uid, "chown() - blah with space.txt");
   ok($stat{gid} == 0, "chown() - blah with space.txt (gid == 0)");
   %stat = ();

   chown "nobody", "/tmp/blah-copy/*";
   %stat = stat "/tmp/blah-copy/blah.txt";
   ok($stat{uid} == $uid, "chown() - blah.txt");
   ok($stat{gid} == 0, "chown() - blah.txt (gid == 0)");
   %stat = ();

   %stat = stat "/tmp/blah-copy/blah with space2.txt";
   ok($stat{uid} == $uid, "chown() - blah with space2.txt");
   ok($stat{gid} == 0, "chown() - blah with space2.txt (gid == 0)");
   %stat = ();

   chgrp "nobody", "/tmp/blah-copy/blah with space.txt";
   %stat = ();
   %stat = stat "/tmp/blah-copy/blah with space.txt";
   ok($stat{gid} == $gid, "chgrp() - blah with space.txt (gid == $gid)");
   %stat = ();

   chgrp "nobody", "/tmp/blah-copy/*";
   %stat = stat "/tmp/blah-copy/blah.txt";
   ok($stat{gid} == $gid, "chgrp() - blah.txt (gid == $gid)");
   %stat = ();

   %stat = stat "/tmp/blah-copy/blah with space2.txt";
   ok($stat{gid} == $gid, "chgrp() - blah with space2.txt (gid == $gid)");
   %stat = ();


   chmod 700, "/tmp/blah-copy/blah with space.txt";
   %stat = ();
   %stat = stat "/tmp/blah-copy/blah with space.txt";
   ok($stat{mode} == 700, "chmod() - blah with space.txt");
   %stat = ();

   chmod 700, "/tmp/blah-copy/*";
   %stat = stat "/tmp/blah-copy/blah.txt";
   ok($stat{mode} == 700, "chmod() - blah.txt");
   %stat = ();

   %stat = stat "/tmp/blah-copy/blah with space2.txt";
   ok($stat{mode} == 700, "chmod() - blah with space2.txt");
   %stat = ();
  
   unlink "/tmp/blah-copy/blah with space.txt";
   ok(! is_file("/tmp/blah-copy/blah with space.txt"), "is_file() - blah with space.txt NOT exist (blah-copy)");

   rmdir "/tmp/blah-copy/*";
   ok(! is_file("/tmp/blah-copy/blah.txt"), "is_file() - blah.txt NOT exist (blah-copy)");

   rmdir "/tmp/blah-copy";

   rmdir "/tmp/foo dir";
   ok(! is_dir("/tmp/foo dir"), "/tmp/foo dir doesnt exists");

   done_testing();

};

