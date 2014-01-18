# vim: set syn=perl:
use Rex -feature => 0.42;
use Rex::Commands::Rsync;
use Test::More;

do "auth.conf";

include qw/Rex::Ext::Backup/;

my $pid = $$;
set backup_location => "/tmp/$pid/backup/%h";


task "test", group => "test", sub {

   LOCAL {
      mkdir "/tmp/$pid/backup";
   };

   file "/etc/test.file", content => "foo";

   file "/etc/test.file", content => "bar";

   my $server = connection->server;

   LOCAL {
      my $content = cat "/tmp/$pid/backup/$server/etc/test.file";
      ok($content eq "foo", "backup done");
   };

   done_testing();
};

