# vim: set syn=perl:

use Rex -feature => '0.42';
use Test::More;
use Capture::Tiny qw'capture';

do "auth.conf";

task test => group => test => sub {

   sayformat '%h: %s';
   my ($stdout) = capture {
      say "hello world";
   };

   my $test_string = connection->server . ": hello world\n";
   ok($stdout eq $test_string, 'sayformat %h: %s');

   sayformat '[%D](%p) %h: %s';
   my ($stdout) = capture {
      say "hello world";
   };

   my $time_stamp = Rex::Commands::_get_timestamp();

   $test_string = "[$time_stamp]($$) " . connection->server . ": hello world\n";
   ok($stdout eq $test_string, 'sayformat [%D](%p) %h: %s');


   done_testing();
};

