package Foo;

use Rex -base;
use Test::More;
use Data::Dumper;

task "bar", sub {
   unlink "/tmp/foo.txt";
   unlink "/tmp/bar.txt";
   unlink "/tmp/baz.txt";

   file "/tmp/foo.txt", source => "files/foo.txt";
   ok(is_file("/tmp/foo.txt"), "found foo.txt");
   my $content = cat("/tmp/foo.txt");
   ok($content =~ m/foo\.txt/, "content of foo.txt");
   unlink "/tmp/foo.txt";
   $content = undef;

   file "/tmp/bar.txt", source => "files/bar.txt", owner => "root";
   ok(is_file("/tmp/bar.txt"), "found bar.txt");
   my %stat = stat("/tmp/bar.txt");
   ok($stat{uid} == 0, "uid is 0");
   append_if_no_such_line "/tmp/bar.txt", "woohaa", qr{woohaa};
   $content = cat("/tmp/bar.txt");
   ok($content =~ m/^bar\.txt/, "content of bar.txt");
   ok($content =~ m/woohaa/, "woohaa found");
   unlink "/tmp/bar.txt";
   $content = undef;

   file "/tmp/baz.txt", source => "files/baz.txt";
   ok(is_file("/tmp/baz.txt"), "found baz.txt");
   $content = cat("/tmp/baz.txt");
   ok($content =~ m/^module\/baz\.txt/, "content of baz.txt");
   unlink "/tmp/baz.txt";
   $content = undef;

   install file => "/tmp/foo.txt", {
      source => "files/foo.txt",
   };
   ok(is_file("/tmp/foo.txt"), "found foo.txt");
   $content = cat("/tmp/foo.txt");
   ok($content =~ m/foo\.txt/, "content of foo.txt");
   unlink "/tmp/foo.txt";
   $content = undef;

   install file => "/tmp/bar.txt", {
      source => "files/bar.txt",
   };
   ok(is_file("/tmp/bar.txt"), "found bar.txt");
   $content = cat("/tmp/bar.txt");
   ok($content =~ m/^bar\.txt/, "content of bar.txt");
   unlink "/tmp/bar.txt";
   $content = undef;

   # altes verhalten fuer compat.
   install file => "/tmp/baz.txt", {
      source => "files/blah.txt",
   };
   ok(is_file("/tmp/baz.txt"), "found baz.txt");
   $content = cat("/tmp/baz.txt");
   ok($content =~ m/^blah\.txt/, "content of baz.txt");
   unlink "/tmp/baz.txt";
   $content = undef;

};

1;
