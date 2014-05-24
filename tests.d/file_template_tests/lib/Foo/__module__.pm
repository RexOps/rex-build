package Foo;

use Rex -base;
use Test::More;

task "bar", sub {
  unlink "/tmp/foo.txt";
  unlink "/tmp/bar.txt";
  unlink "/tmp/baz.txt";

  file "/tmp/foo.txt", content => template("files/foo.txt");
  ok(is_file("/tmp/foo.txt"), "found foo.txt");
  my $content = cat("/tmp/foo.txt");
  ok($content =~ m/foo\.txt/, "content of foo.txt");
  unlink "/tmp/foo.txt";
  $content = undef;

  file "/tmp/bar.txt", content => template("files/bar.txt");
  ok(is_file("/tmp/bar.txt"), "found bar.txt");
  $content = cat("/tmp/bar.txt");
  ok($content =~ m/^bar\.txt/, "content of bar.txt");
  unlink "/tmp/bar.txt";
  $content = undef;

  file "/tmp/baz.txt", content => template("files/baz.txt");
  ok(is_file("/tmp/baz.txt"), "found baz.txt");
  $content = cat("/tmp/baz.txt");
  ok($content =~ m/^module\/baz\.txt/, "content of baz.txt");
  unlink "/tmp/baz.txt";
  $content = undef;

  my $x = template('@test.tpl', name => 'foo');
  ok($x =~ m/this is another test: foo/ms, 'template in data section (__module__.pm)');

};


1;

__DATA__

@test.tpl
this is another test: <%= $name %>
@end
