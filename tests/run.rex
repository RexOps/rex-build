# vim: set syn=perl:

use Rex -feature => '0.42';
use Test::More;

do "auth.conf";

task test => group => test => sub {

   my $basic = run 'uptime';
   ok($basic =~ m/load average/, "OK: Basic invocation of run");

   my $chain = run 'FOOV=blah ; echo $FOOV';
   ok($chain =~ m/blah/, "OK: command chaining");

   my $esc = run 'echo \$"FOO"';
   ok($esc =~ m/\$FOO/, "OK: Shell escape");

   my $path = run 'echo $PATH', path => '/tmp';
   ok($path eq "/tmp", "used custom path");


   if(is_freebsd) {

      my $desc1 = run 'set FOOV=blub ; echo "\'$FOOV\'"';
      ok($desc1 =~ m/'blub'/, "OK: Escape");

      my $desc2 = run 'set FOOV=foobarbaz ; echo \'"$FOOV"\'';
      ok($desc2 =~ m/"\$FOOV"/, 'OK: Escape 2');

      my $okcwd = run "pwd", cwd => "/etc";
      ok($okcwd eq "/etc", "OK: executed in /etc directory via cwd");

      my $badcwd = run "pwd", cwd => "/dfdfjhdfj";
      ok($badcwd =~ m/No such file/ && $? != 0, "OK: error changing directory, \$? != 0");

   }
   else {

      my $desc1 = run 'FOOV=blub ; echo "\'$FOOV\'"';
      ok($desc1 =~ m/'blub'/, "OK: Escape");

      my $desc2 = run 'FOOV=foobarbaz ; echo \'"$FOOV"\'';
      ok($desc2 =~ m/"\$FOOV"/, 'OK: Escape 2');

      my $okcwd = run "pwd", cwd => "/etc";
      ok($okcwd eq "/etc", "OK: executed in /etc directory via cwd");

      my $badcwd = run "pwd", cwd => "/dfdfjhdfj";
      ok($badcwd !~ m/^\// && $? != 0, "OK: error changing directory, \$? != 0");

   }

   my $or = run 'touch /bla/foo/baz/file || touch /tmp/fafafafa';
   ok(is_file("/tmp/fafafafa"), 'OK: OR chaining works');


   my $and = run 'touch /tmp/fufufufu && touch /tmp/fofofofo';
   ok(is_file("/tmp/fofofofo"), 'OK: AND chaining works');

   my $check_0 = run 'grep -c sdfsdf /etc/passwd';
   ok($check_0 eq "0", "got 0 as answer");


   done_testing();
};

