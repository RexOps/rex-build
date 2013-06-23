package Software::myscript;

use Rex -base;
use Test::More;

task "test", sub {

   my $base_dir = "/tmp/file3-test";

   if(is_dir($base_dir)) {
      rmdir $base_dir;
   }

   mkdir $base_dir;

   upload "files/myscript.sh", "$base_dir";
   ok(is_file("$base_dir/myscript.sh"), "myscript: upload to directory");
   my $content = cat("$base_dir/myscript.sh");
   ok($content =~ m/myscript\.sh/, "myscript: standard file found");
   unlink "$base_dir/myscript.sh";
   $content = undef;

   upload "files/myscript.sh", "$base_dir/myother.sh";
   ok(is_file("$base_dir/myother.sh"), "myscript: upload to directory/myother.sh");
   $content = cat("$base_dir/myother.sh");
   ok($content =~ m/myscript\.sh/, "myscript: standard file found");
   unlink "$base_dir/myother.sh";
   $content = undef;

   file "$base_dir/file-myscript.sh",
      source => "files/myscript.sh";
   ok(is_file("$base_dir/file-myscript.sh"), "myscript: file() with relative source");
   $content = cat("$base_dir/file-myscript.sh");
   ok($content =~ m/myscript\.sh/, "myscript: standard file found");
   unlink "$base_dir/myscript.sh";
   $content = undef;

   file "$base_dir/file-mytempl.sh",
      source => "templates/mytempl.sh";
   ok(is_file("$base_dir/file-mytempl.sh"), "myscript: file() with template and relative source");
   $content = cat("$base_dir/file-mytempl.sh");
   ok($content =~ m/mytempl\.sh/, "myscript: template file found");
   unlink "$base_dir/file-mytempl.sh";
   $content = undef;



   rmdir $base_dir;
};


task "test_env", sub {

   my $base_dir = "/tmp/file3-test-env";

   if(is_dir($base_dir)) {
      rmdir $base_dir;
   }

   mkdir $base_dir;

   upload "files/myscript.sh", "$base_dir";
   ok(is_file("$base_dir/myscript.sh"), "myscript: upload to directory - with env");
   my $content = cat("$base_dir/myscript.sh");
   ok($content =~ m/myscript\.prod/, "myscript: standard file found - with env");
   unlink "$base_dir/myscript.sh";
   $content = undef;

   upload "files/myscript.sh", "$base_dir/myother.sh";
   ok(is_file("$base_dir/myother.sh"), "myscript: upload to directory/myother.sh - with env");
   $content = cat("$base_dir/myother.sh");
   ok($content =~ m/myscript\.prod/, "myscript: standard file found - with env");
   unlink "$base_dir/myother.sh";
   $content = undef;

   file "$base_dir/file-myscript.sh",
      source => "files/myscript.sh";
   ok(is_file("$base_dir/file-myscript.sh"), "myscript: file() with relative source - with env");
   $content = cat("$base_dir/file-myscript.sh");
   ok($content =~ m/myscript\.prod/, "myscript: standard file found - with env");
   unlink "$base_dir/myscript.sh";
   $content = undef;

   file "$base_dir/file-mytempl.sh",
      source => "templates/mytempl.sh";
   ok(is_file("$base_dir/file-mytempl.sh"), "myscript: file() with template and relative source - with env");
   $content = cat("$base_dir/file-mytempl.sh");
   ok($content =~ m/mytempl\.prod/, "myscript: template file found - with env");
   unlink "$base_dir/file-mytempl.sh";
   $content = undef;


   rmdir $base_dir;


};

1;
