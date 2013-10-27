# vim: set syn=perl:
use Rex -feature => 0.42;
use Test::More;

do "auth.conf";

require Foo;

task "test", group => "test", sub {

   Foo::bar();

   mkdir "/tmp/etc";
   sync_up "files/etc/", "/tmp/etc",
           on_change => sub {
               my (@changed_files) = @_;

               my ($found1) = grep { $_ =~ /file1.txt/ } @changed_files;
               my ($found2) = grep { $_ =~ /file2.txt/ } @changed_files;
               my ($found3) = grep { $_ =~ /file3.txt/ } @changed_files;

               ok($found1, "file1.txt was changed");
               ok($found2, "file2.txt was changed");
               ok($found3, "file3.txt was changed");
           };

   sync_up "files/etc/", "/tmp/etc",
           on_change => sub {
               my (@changed_files) = @_;

               my ($found1) = grep { $_ =~ /file1.txt/ } @changed_files;
               my ($found2) = grep { $_ =~ /file2.txt/ } @changed_files;
               my ($found3) = grep { $_ =~ /file3.txt/ } @changed_files;

               ok(! $found1, "file1.txt was not changed");
               ok(! $found2, "file2.txt was not changed");
               ok(! $found3, "file3.txt was not changed");
           };



   done_testing();

};

1;
