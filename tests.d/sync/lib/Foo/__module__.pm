package Foo;

use Rex -base;
use Test::More;
use Data::Dumper;

task "bar", sub {

   my $base_dir = "/tmp/sync-test";

   if(is_dir($base_dir)) {
      rmdir $base_dir;
   }

   set name => "Joe";

   mkdir $base_dir;
   mkdir "$base_dir/sync";
   sync_up "files/", "$base_dir/sync";

   ok(is_file("$base_dir/sync/bar.txt"), "sync - bar.txt");
   my $content = cat("$base_dir/sync/bar.txt");
   ok($content =~ m/bar\.txt/, "bar.txt found");
   $content = undef;

   ok(is_file("$base_dir/sync/foo.txt"), "sync - foo.txt");
   $content = cat("$base_dir/sync/foo.txt");
   ok($content =~ m/foo\.txt/, "foo.txt found");
   $content = undef;

   ok(is_file("$base_dir/sync/subdir/more.txt"), "sync - subdir/more.txt");
   $content = cat("$base_dir/sync/subdir/more.txt");
   ok($content =~ m/more\.txt/, "subdir/more.txt found");
   $content = undef;

   ok(is_file("$base_dir/sync/subdir/listen"), "sync - subdir/listen");
   $content = cat("$base_dir/sync/subdir/listen");
   ok($content =~ m/Listen 10\.211\.55/, "sync - template ipaddress");
   $content = undef;

   ok(is_file("$base_dir/sync/baz.txt"), "sync - baz.txt");
   $content = cat("$base_dir/sync/baz.txt");
   ok($content =~ m/Hello Joe/, "sync - template name");
   $content = undef;

};
