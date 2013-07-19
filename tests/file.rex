# vim: set syn=perl:
use Rex -feature => '0.42';
use Test::More;
use Cwd 'getcwd';

do "auth.conf";

my $cwd = getcwd;

task test => group => test => sub {

   my $fh = file_write "/tmp/test.txt";
   $fh->write("Test\n");
   $fh->close;

   ok(is_file("/tmp/test.txt"), "/tmp/test.txt exists");

   my $fhr = file_read "/tmp/test.txt";
   my @content = $fhr->read_all;
   $fh->close;
   ok($content[0] eq "Test", "content is ok");
   my $fha = file_append "/tmp/test.txt";
   $fha->write("Hello Jan\n");
   $fha->write("Blah\n");
   $fha->close;

   $fhr = file_read "/tmp/test.txt";
   @content = $fhr->read_all;
   $fhr->close;

   ok($content[1] eq "Hello Jan", "content check 2");

   eval {
      delete_lines_matching "/tmp/test.txt" => "Jan";
   };

   ok(! $@, "delete_lines_matching eval...");

   $fhr = file_read "/tmp/test.txt";
   @content = $fhr->read_all;
   $fhr->close;

   ok($content[1] eq "Blah", "delete_lines_matching (string)");

   delete_lines_matching "/tmp/test.txt" => qr{blah}i;

   $fhr = file_read "/tmp/test.txt";
   @content = $fhr->read_all;
   $fhr->close;

   ok(scalar(@content) == 1, "delete_lines_matching (regex)");

   append_if_no_such_line "/tmp/test.txt", "Test99", qr{Test99};

   $fhr = file_read "/tmp/test.txt";
   @content = $fhr->read_all;
   $fhr->close;
   ok($content[-1] eq "Test99", "append_if_no_such_lines");

   # don't add something
   append_if_no_such_line "/tmp/test.txt", "Test100", qr{Test};

   $fhr = file_read "/tmp/test.txt";
   @content = $fhr->read_all;
   $fhr->close;
   ok($content[-1] eq "Test99", "append_if_no_such_line with regex");

   my $changed = 0;
   append_if_no_such_line "/tmp/test.txt", "change", qr{change}, 
      on_change => sub {
         $changed = 1;
      };

   ok($changed == 1, "something was changed in the file");

   append_if_no_such_line "/tmp/test.txt", "change", qr{change}, 
      on_change => sub {
         $changed = 0;
      };

   ok($changed == 1, "nothing was changed in the file");

   unlink "/tmp/test.txt";
   ok(!is_file("/tmp/test.txt"), "file deleted");

   file "/tmp/foo.bar",
      source => "/etc/passwd";

   ok(is_file("/tmp/foo.bar"), "/tmp/foo.bar exists");  
   ok(!is_dir("/tmp/foo.bar"), "/tmp/foo.bar exists and is not a dir");  

   my $i = cat "/tmp/foo.bar";
   ok($i =~ m/root/m, "/tmp/foo.bar has content");

   rm "/tmp/foo.bar";
   ok(!is_file("/tmp/foo.bar"), "/tmp/foo.bar deleted");

   file "/tmp/foo.bar2",
      content => template("file/test.tpl");

   ok(is_file("/tmp/foo.bar2"), "/tmp/foo.bar2 exists");

   my $i2 = cat "/tmp/foo.bar2";
   ok($i2 =~ m/\@array/m, "found \@array");
   ok($i2 =~ m/\%heho/m, "found \%heho");
   ok($i2 =~ m/\$bla/m, "found \$bla");

   unlink "/tmp/foo.bar2";
   ok(!is_file("/tmp/foo.bar2"), "file removed");

   file "/tmp/foo.bar3",
      content => "blah";

   my $i3 = cat "/tmp/foo.bar3";
   ok($i3 =~ m/blah/, "file function with content");

   file "/tmp/foo.bar4",
      source => "tests/file/test.txt";
   
   my $i4 = cat "/tmp/foo.bar4";
   ok($i4 =~ m/blub/, "file function with source");

   file "/tmp/foo.bar5",
      source => "$cwd/tests/file/test.txt";

   my $i5 = cat "/tmp/foo.bar5";
   ok($i5 =~ m/blah/, "file function with source and absolute path");

   done_testing();
};

