package Foo;

use Rex -base;
use Test::More;

task "bar", sub {

  unlink "/tmp/foo.txt";
  unlink "/tmp/bar.txt";
  unlink "/tmp/baz.txt";

  upload "files/foo.txt", "/tmp";
  ok(is_file("/tmp/foo.txt"), "found foo.txt");
  my $content = cat("/tmp/foo.txt");
  ok($content =~ m/foo\.txt/, "content of foo.txt");
  unlink "/tmp/foo.txt";
  $content = undef;

  upload "files/bar.txt", "/tmp";
  ok(is_file("/tmp/bar.txt"), "found bar.txt");
  $content = cat("/tmp/bar.txt");
  ok($content =~ m/^bar\.txt/, "content of bar.txt");
  unlink "/tmp/bar.txt";
  $content = undef;

  upload "files/baz.txt", "/tmp";
  ok(is_file("/tmp/baz.txt"), "found baz.txt");
  $content = cat("/tmp/baz.txt");
  ok($content =~ m/^module\/baz\.txt/, "content of baz.txt");
  unlink "/tmp/baz.txt";
  $content = undef;


};


1;
