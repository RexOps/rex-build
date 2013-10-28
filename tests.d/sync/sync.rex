# vim: set syn=perl:
use Rex -feature => 0.42;
use Test::More;

do "auth.conf";

require Foo;

task "test", group => "test", sub {

   Foo::bar();

   mkdir "/tmp/etc";
   my $on_changed_called = 0;
   sync_up "files/etc/", "/tmp/etc",
           on_change => sub {
               my (@changed_files) = @_;

               my ($found1) = grep { $_ =~ /file1.txt/ } @changed_files;
               my ($found2) = grep { $_ =~ /file2.txt/ } @changed_files;
               my ($found3) = grep { $_ =~ /file3.txt/ } @changed_files;

               ok($found1, "file1.txt was changed");
               ok($found2, "file2.txt was changed");
               ok($found3, "file3.txt was changed");

               $on_changed_called = 1;
           };

   ok($on_changed_called, "on_change was called (sync_up)");
   $on_changed_called = 0;

   sync_up "files/etc/", "/tmp/etc",
           on_change => sub {
               my (@changed_files) = @_;
               $on_changed_called = 1;
           };

   ok($on_changed_called == 0, "on_change was not called (sync_up)");
   $on_changed_called = 0;

   LOCAL { mkdir "tmp"; };
   sync_down "/tmp/etc", "tmp",
      on_change => sub {
         my (@changed_files) = @_;

         my ($found1) = grep { $_ =~ /file1.txt/ } @changed_files;
         my ($found2) = grep { $_ =~ /file2.txt/ } @changed_files;
         my ($found3) = grep { $_ =~ /file3.txt/ } @changed_files;

         ok($found1, "file1.txt was changed");
         ok($found2, "file2.txt was changed");
         ok($found3, "file3.txt was changed");

         $on_changed_called = 1;
      };

   ok($on_changed_called, "on_change was called (sync_down)");
   $on_changed_called = 0;

   my $ds = "/tmp/etc-" . connection->server;
   sync_down $ds, "tmp",
      on_change => sub {
         my (@changed_files) = @_;
         $on_changed_called = 1;
      };

   ok($on_changed_called == 0, "on_change was not called (sync_down)");
   $on_changed_called = 0;

   rmdir $ds;


   done_testing();

};

1;
