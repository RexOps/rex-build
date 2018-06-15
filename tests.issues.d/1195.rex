# vim: set syn=perl:
use Test::More;

do 'auth.conf';

use Rex::Helper::Path;

task test => group => test => sub {
  my $tmp_dir = "/tmp/x";
  file $tmp_dir, ensure => 'directory';
  ok( is_dir($tmp_dir), 'create a temporary directory' );

  my $sub_dir1 = "$tmp_dir/sub1";
  my $sub_dir2 = "$tmp_dir/sub2";

  file $sub_dir1, ensure => 'directory';
  file $sub_dir2, ensure => 'directory';

  my $source_file = "$sub_dir1/source.txt";
  file $source_file, content => 'foo=bar';
  ok( is_file($source_file), 'file exists' );

  my $content = cat($source_file);
  is( $content, "foo=bar\n", 'file contents' );

  my $symlink = "$sub_dir2/symlink";
  symlink '../sub1/source.txt', $symlink;
  ok( is_symlink($symlink), 'create symlink' );

  my $changed;
  append_or_amend_line $symlink,
    line      => 'foo=new',
    regexp    => qr{^foo=},
    on_change => sub {
      $changed++;
    };

  is( $changed,      1,           'append_or_amend_line on_changed' );
  is( cat($symlink), "foo=new\n", 'append_or_amend_line line' );
  ok( is_symlink($symlink), 'is_symlink' );

  done_testing();

};