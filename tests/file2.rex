# vim: set syn=perl:

use Rex -feature => '0.42';
use Rex::Commands::Rsync;
use Test::More;
use Cwd 'getcwd';

unshift @INC, "tests/file2/lib";

user $ENV{REXUSER};
password $ENV{REXPASS};
pass_auth;

if(exists $ENV{use_sudo}) {
   sudo_password $ENV{REXPASS};
   sudo -on;
}

if(exists $ENV{openssh}) {
   set connection => 'OpenSSH';
}

group test => $ENV{HTEST};

my $cwd = getcwd;


include qw/Software::myscript Software::myrsync/;

task test => group => test => sub {

   my $base_dir = "/tmp/file2-test";

   if(is_dir($base_dir)) {
      rmdir $base_dir;
   }

   mkdir $base_dir;

   upload "tests/file2/files/upload.txt", "$base_dir";
   ok(is_file("$base_dir/upload.txt"), "upload to directory");
   my $content = cat("$base_dir/upload.txt");
   ok($content =~ m/upload\.txt/, "standard file found");
   unlink "$base_dir/upload.txt";
   $content = undef;

   upload "tests/file2/files/upload.txt", "$base_dir/foo.txt";
   ok(is_file("$base_dir/foo.txt"), "upload to directory/foo.txt");
   $content = cat("$base_dir/foo.txt");
   ok($content =~ m/upload\.txt/, "foo.txt file found");
   unlink "$base_dir/foo.txt";
   $content = undef;

   file "$base_dir/file-upload.txt",
      source => "tests/file2/files/upload.txt";
   ok(is_file("$base_dir/file-upload.txt"), "file() with relative source");
   $content = cat("$base_dir/file-upload.txt");
   ok($content =~ m/upload\.txt/, "file-upload.txt file found");
   unlink "$base_dir/file-upload.txt";
   $content = undef;

   file "$base_dir/template-file.txt",
      content => template("tests/file2/templates/templ.txt");
   ok(is_file("$base_dir/template-file.txt"), "file() with template and relative source");
   $content = cat("$base_dir/template-file.txt");
   ok($content =~ m/templ\.txt/, "template-file.txt file found");
   unlink "$base_dir/template-file.txt";
   $content = undef;

=begin

   mkdir "$base_dir/rsync";
   sync "rsync/*", "$base_dir/rsync";

   ok(is_file("$base_dir/rsync/bar.txt"), "rsync - bar.txt");
   $content = cat("$base_dir/rsync/bar.txt");
   ok($content =~ m/bar\.txt/, "bar.txt found");
   $content = undef;

   ok(is_file("$base_dir/rsync/foo.txt"), "rsync - foo.txt");
   $content = cat("$base_dir/rsync/foo.txt");
   ok($content =~ m/foo\.txt/, "foo.txt found");
   $content = undef;

   ok(is_file("$base_dir/rsync/subdir/more.txt"), "rsync - subdir/more.txt");
   $content = cat("$base_dir/rsync/subdir/more.txt");
   ok($content =~ m/more\.txt/, "subdir/more.txt found");
   $content = undef;

=cut

   Software::myscript::test();
#   Software::myrsync::test();

##### tests with environment prod

   Rex::Config->set_environment("prod");
   upload "tests/file2/files/upload.txt", "$base_dir";
   ok(is_file("$base_dir/upload.txt"), "upload to directory with env");
   $content = cat("$base_dir/upload.txt");
   ok($content =~ m/upload\.prod/, "environment file found");
   unlink "$base_dir/upload.txt";
   $content = undef;

   file "$base_dir/file-upload.txt",
      source => "tests/file2/files/upload.txt";
   ok(is_file("$base_dir/file-upload.txt"), "file() with relative source and environment");
   $content = cat("$base_dir/file-upload.txt");
   ok($content =~ m/upload\.prod/, "file-upload.txt file found");
   unlink "$base_dir/file-upload.txt";
   $content = undef;

   file "$base_dir/template-file.txt",
      content => template("tests/file2/templates/templ.txt");
   ok(is_file("$base_dir/template-file.txt"), "file() with template and relative source and environment");
   $content = cat("$base_dir/template-file.txt");
   ok($content =~ m/templ\.prod/, "template-file.txt file found");
   unlink "$base_dir/template-file.txt";
   $content = undef;

   Software::myscript::test_env();

   rmdir "$base_dir";



   done_testing();
};

