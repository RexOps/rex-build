use Rex -feature => ['0.42'];

use Rex::Commands::MD5;
use Data::Dumper;
use Test::More;

do "auth.conf";

task "test", group => "test", sub {

  my $home = run 'echo $HOME';
  my $local_home;
  LOCAL {
    $local_home = run 'echo $HOME';
  };
  
  mkdir "~/test";
  ok(is_dir("$home/test"), "found test directory in $home");
  ok(is_dir("~/test"), "found test directory in $home with tilde");

  rmdir "~/test";
  ok(! is_dir("$home/test"), "removed test directory in $home");

  file "~/test.txt", content => "this is a test\n";
  ok(is_file("$home/test.txt"), "found test.txt in $home");

  rename "~/test.txt", "~/test2.txt";
  ok(is_file("$home/test2.txt"), "found test2.txt in $home");
  ok(! is_file("$home/test.txt"), "renamed test.txt in $home");

  cp "~/test2.txt", "~/test3.txt";
  ok(is_file("$home/test3.txt"), "found test3.txt in $home");

  unlink "~/test2.txt", "~/test3.txt";
  ok(! is_file("$home/test2.txt"), "removed test2.txt in $home");
  ok(! is_file("$home/test3.txt"), "removed test3.txt in $home");

  upload "/etc/passwd", "~/test.file";
  ok(is_file("$home/test.file"), "uploaded test.file to $home");

  download "~/test.file", "/tmp/test.file";
  LOCAL {
    ok(is_file("/tmp/test.file"), "download test.file from $home");
  };

  download "~/test.file", "~/test.file";
  LOCAL {
    ok(is_file("$local_home/test.file"), "download test.file from $home to $local_home");
  };

  upload "~/test.file", "~/test2.file";
  ok(is_file("$home/test2.file"), "uploaded test2.file to $home");

  LOCAL {
    rm "~/test.file";
    ok(! is_file("$local_home/test.file"), "local test.file removed");
    ok(! is_file("~/test.file"), "local test.file removed, test with tilde");
  };

  mkdir "~rsync_user/foo";
  ok(is_dir("/home/rsync_user/foo"), "created foo folder inside rsync_user \$HOME");

  done_testing();
};

