package Foo;

use Rex -base;
use Test::More;
use Data::Dumper;

task "bar", sub {

	my $orig_md5 = "5f363e0e58a95f06cbe9bbc662c5dfb6";

	upload "files/file.bin", "/tmp";

	ok(is_file("/tmp/file.bin"), "OK: something was uploaded");

	ok($orig_md5 eq md5("/tmp/file.bin"), "OK: remote md5 okay");

	rm "/tmp/file.bin";
};
