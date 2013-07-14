package Foo::Bar::Gee;

use Rex -base;
use Test::More;

task "test", sub {

   unlink "/tmp/foo.txt";
   unlink "/tmp/bar.txt";
   unlink "/tmp/baz.txt";

   file "/tmp/bar.txt", content => template("../files/bar.txt");
   ok(is_file("/tmp/bar.txt"), "found bar.txt");
   my $content = cat("/tmp/bar.txt");
   ok($content =~ m/^foo\/bar\.txt/, "content of bar.txt");
   unlink "/tmp/bar.txt";
   $content = undef;

   file "/tmp/baz.txt", content => template("../files/baz.txt");
   ok(is_file("/tmp/baz.txt"), "found baz.txt");
   $content = cat("/tmp/baz.txt");
   ok($content =~ m/^module\/baz\.txt/, "content of baz.txt");
   unlink "/tmp/baz.txt";
   $content = undef;

};

1;
