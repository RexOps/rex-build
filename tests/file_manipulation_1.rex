# vim: set syn=perl:

use Rex -feature => '0.42';
use Rex::Commands::File;
use Rex::Commands::Fs;
use Rex::Commands::User;
use Test::More;

do "auth.conf";

desc "test";
task "test", group => "test", sub {

  file "/tmp/foo-file.txt",
    content => "this is
\tsome content
bazz dada
foobar";

  my $content = cat "/tmp/foo-file.txt";
  ok($content eq "this is\n\tsome content\nbazz dada\nfoobar\n", "file written");

  sed qr{\tsome}, "some", "/tmp/foo-file.txt";

  $content = cat "/tmp/foo-file.txt";
  ok($content eq "this is\nsome content\nbazz dada\nfoobar\n", "file manipulated");

  delete_lines_according_to qr{this is}, "/tmp/foo-file.txt",
    on_change => sub {
      my ($file) = @_;
      ok($file eq "/tmp/foo-file.txt", "file was changed");
    };

  $content = cat "/tmp/foo-file.txt";
  ok($content eq "some content\nbazz dada\nfoobar\n", "delete lines according");

  delete_lines_according_to qr{dada|foobar}, "/tmp/foo-file.txt";

  $content = cat "/tmp/foo-file.txt";
  ok($content eq "some content\n", "delete lines according, regexp with or");

  my $changed = 0;
  delete_lines_according_to qr{^content}, "/tmp/foo-file.txt",
    on_change => sub {
      $changed = 100;
    };

  ok($changed == 0, "file was not changed");
  $content = cat "/tmp/foo-file.txt";
  ok($content eq "some content\n", "file was not changed, some content");



  unlink "/tmp/foo-file.txt";

  file "/tmp/test-sed.txt",
    content => "this is a sed test file\nthese are just some lines\n0505\n0606\n0707\n'foo'\n/etc/passwd\n\"baz\"\n{klonk}\nfoo bar\n\\.-~'[a-z]\$ foo {1} /with/some/slashes \%\&()?\n|.-\\~'[a-z]\$ bar {2} /with/more/slashes \%\&()?\n";

  sed qr/fo{2} bar/, q/fjdif jf "lfkdfdf'skdlffdf'dkfldsf" "c df  [df-r]' \/dkfj sfd \\ +* ~ $foo/, "/tmp/test-sed.txt";
  $content = cat "/tmp/test-sed.txt";
  ok($content =~ m/fjdif jf "lfkdfdf'skdlffdf'dkfldsf" "c df  \[df\-r\]' \/dkfj sfd \\ \+\* ~ \$foo/, "sed replaced foo bar with special chars");

  sed qr/^\\\.\-\~'\[a\-z\]\$ foo \{1\} \/with\/some\/slashes/, "got replaced", "/tmp/test-sed.txt";
  $content = cat "/tmp/test-sed.txt";
  ok($content =~ m/got replaced/, "sed replaced strange chars");

  sed qr/^\|\.\-\\\~'\[a\-z\]\$ BAR \{2\} \/with\/more\/slashes/i, "got another replace", "/tmp/test-sed.txt";
  $content = cat "/tmp/test-sed.txt";
  ok($content =~ m/got another replace/, "sed replaced strange chars");

  my @lines = split(/\n/, $content);
  ok($lines[-1] =~ m/^got another replace/, "last line was successfully replaced");
  ok($lines[-2] =~ m/^got replaced/, "second last line was successfully replaced");
  ok($lines[-4] =~ m/^\{klonk\}/, "fourth last line untouched");

  sed qr{0606}, "6666", "/tmp/test-sed.txt";
  $content = cat "/tmp/test-sed.txt";
  ok($content =~ m/6666/, "sed replaced 0606");

  sed qr{'foo'}, "'bar'", "/tmp/test-sed.txt";
  $content = cat "/tmp/test-sed.txt";
  ok($content =~ m/'bar'/, "sed replaced 'foo'");

  sed qr{/etc/passwd}, "/etc/shadow", "/tmp/test-sed.txt";
  $content = cat "/tmp/test-sed.txt";
  ok($content =~ m/\/etc\/shadow/, "sed replaced /etc/passwd");

  sed qr{"baz"}, '"boooooz"', "/tmp/test-sed.txt";
  $content = cat "/tmp/test-sed.txt";
  ok($content =~ m/"boooooz"/, "sed replaced baz");

  sed qr/{klonk}/, '{plonk}', "/tmp/test-sed.txt";
  $content = cat "/tmp/test-sed.txt";
  ok($content =~ m/{plonk}/, "sed replaced {klonk}");

  sed qr/{klonk}/, '{plonk}', "/tmp/test-sed.txt";
  $content = cat "/tmp/test-sed.txt";
  ok($content =~ m/{plonk}/, "sed replaced {klonk}");


  done_testing();

};

