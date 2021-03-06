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

  append_if_no_such_line "/tmp/test.txt",
    line => "#include /etc/sudoers.d/*.conf",
    regexp => qr{^#include /etc/sudoers.d/\*\.conf$};

  $fhr = file_read "/tmp/test.txt";
  @content = $fhr->read_all;
  $fhr->close;
  ok($content[-1] eq "#include /etc/sudoers.d/*.conf", "append_if_no_such_lines - with path, ^ and \$ in regexp");


  # something with quotes
  append_if_no_such_line "/tmp/test.txt",
    line => 'this is with "quotes", checked?',
    regexp => qr{this is with "quotes", checked\?};
  $fhr = file_read "/tmp/test.txt";
  @content = $fhr->read_all;
  $fhr->close;
  ok($content[-1] eq 'this is with "quotes", checked?', "append_if_no_such_lines - with quotes");


  append_if_no_such_line "/tmp/test.txt",
    line => "#include /etc/sudoers.d/*.conf";
  $fhr = file_read "/tmp/test.txt";
  @content = $fhr->read_all;
  $fhr->close;
  ok($content[-1] ne "#include /etc/sudoers.d/*.conf", "append_if_no_such_lines - try to add second #include line, should not appear");


  append_if_no_such_line "/tmp/test.txt",
    line => "#include /etc/sudoers.d/*.conf",
    regexp => qr{^#include /etc/sudoers.d/\*\.conf$};

  $fhr = file_read "/tmp/test.txt";
  @content = $fhr->read_all;
  $fhr->close;
  ok($content[-1] ne "#include /etc/sudoers.d/*.conf", "append_if_no_such_lines - try to add second #include line, should not appear, with regexp");


  # some crazy chars
  append_if_no_such_line "/tmp/test.txt",
    line => "\\.-~'[a-z]\$ foo {1} \%\&()?",
    regexp => qr/^\\\.\-\~'\[a\-z\]\$ foo \{1\} \%\&\(\)\?$/i;

  $fhr = file_read "/tmp/test.txt";
  @content = $fhr->read_all;
  $fhr->close;
  ok($content[-1] eq "\\.-~'[a-z]\$ foo {1} %&()?", "append_if_no_such_lines - try to add crazy things");

  # some crazy chars with q
  append_if_no_such_line "/tmp/test.txt",
    line => q/this "is" some 'things' with quotes and $other chars .\/5+'#?"~'`  `ls` $sfdkj/;

  $fhr = file_read "/tmp/test.txt";
  @content = $fhr->read_all;
  $fhr->close;
  ok($content[-1] eq q/this "is" some 'things' with quotes and $other chars .\/5+'#?"~'`  `ls` $sfdkj/, "append_if_no_such_lines - adding things with q//");

  # again to verify that it is not doubled, some crazy chars with q
  append_if_no_such_line "/tmp/test.txt",
    line => q/this "is" some 'things' with quotes and $other chars .\/5+'#?"~'`  `ls` $sfdkj/;

  $fhr = file_read "/tmp/test.txt";
  @content = $fhr->read_all;
  $fhr->close;
  ok($content[-1] eq q/this "is" some 'things' with quotes and $other chars .\/5+'#?"~'`  `ls` $sfdkj/, "append_if_no_such_lines - adding things with q// - 2nd time");
  ok($content[-2] ne q/this "is" some 'things' with quotes and $other chars .\/5+'#?"~'`  `ls` $sfdkj/, "append_if_no_such_lines - adding things with q// - not doubled");

  # don't add something
  append_if_no_such_line "/tmp/test.txt", "Test100", qr{Test};

  $fhr = file_read "/tmp/test.txt";
  @content = $fhr->read_all;
  $fhr->close;
  ok($content[-1] ne "Test100", "append_if_no_such_line with regex");

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

  file "/tmp/sed.multiline.replace", content => "this is\na small\ntest\n";
  sed qr/a small\ntest/, "replaced", "/tmp/sed.multiline.replace",
    multiline => TRUE;

  my $smr = cat "/tmp/sed.multiline.replace";
  ok($smr eq "this is\nreplaced\n", "sed multiline replace");

  

  done_testing();
};

