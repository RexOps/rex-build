#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:
  
package Software::myrsync;

use Rex -base;
use Test::More;
use Rex::Commands::Rsync;

task "test", sub {

  my $base_dir = "/tmp/file4-test";

  if(is_dir($base_dir)) {
    rmdir $base_dir;
  }

  mkdir $base_dir;

  mkdir "$base_dir/rsync";
  sync "rsync/*", "$base_dir/rsync";

  ok(is_file("$base_dir/rsync/bar.txt"), "myrsync: rsync - bar.txt");
  my $content = cat("$base_dir/rsync/bar.txt");
  ok($content =~ m/myrsync\/bar\.txt/, "myrsync: bar.txt found");
  $content = undef;

  ok(is_file("$base_dir/rsync/foo.txt"), "myrsync: rsync - foo.txt");
  $content = cat("$base_dir/rsync/foo.txt");
  ok($content =~ m/myrsync\/foo\.txt/, "myrsync: foo.txt found");
  $content = undef;

  ok(is_file("$base_dir/rsync/subdir/more.txt"), "myrsync: rsync - subdir/more.txt");
  $content = cat("$base_dir/rsync/subdir/more.txt");
  ok($content =~ m/myrsync\/more\.txt/, "myrsync: subdir/more.txt found");
  $content = undef;


  rmdir $base_dir;

};

1;
