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

   done_testing();

};

