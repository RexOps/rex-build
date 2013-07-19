use Rex -feature => '0.42';

use Rex::Commands::MD5;
use Data::Dumper;
use Test::More;

user $ENV{REXUSER};
password $ENV{REXPASS};
pass_auth;

if(exists $ENV{use_sudo}) {
   sudo_password $ENV{REXPASS};
   sudo -on;
}

if(exists $ENV{openssh}) {
   set connection => 'OpenSSH';
   Rex::Config->set_openssh_opt(StrictHostKeyChecking => "no");
}

group test => $ENV{HTEST};

task "test", group => "test", sub {

   my $remote_md5 = md5('/etc/passwd');

   download "/etc/passwd", "./passwd.test";

   LOCAL {
      ok(is_file("passwd.test"), "download okay");
      ok($remote_md5 eq md5("passwd.test"), "local md5 okay");

      rm "passwd.test";

      ok(! is_file("passwd.test"), "delete okay");
   };

   done_testing();
};

