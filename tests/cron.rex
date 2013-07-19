use Rex -feature => '0.42';
use Rex::Commands::Cron;

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

task test => group => test => sub {
   run "touch j; crontab j; rm j";

   cron add => "root", {
      minute => "5,10,15",
      hour   => "1,3,5,7",
      command => "/bin/ls /",
   };

   my @crons = cron list => "root";
   #print Dumper(@crons);
   ok($crons[0]->{"command"} eq "/bin/ls /", "Added cron");

   if(! is_solaris) {
      cron env => root => add => {
         MYVAR => "foo",
         MYFOO => "bar",
      };

      my @envs = cron env => root => "list";
      ok($envs[0]->{name} eq "MYVAR", "env MYVAR");
      ok($envs[0]->{value} eq '"foo"', "env MYVAR value");
      ok($envs[1]->{name} eq "MYFOO", "env MYFOO");
      ok($envs[1]->{value} eq '"bar"', "env MYFOO value");
   }

   cron add => "root", {
      minute => "5,10,15",
      hour   => "1,3,5,7",
      command => "uptime",
   };

   @crons = cron list => "root";
   ok($crons[1]->{"command"} eq "uptime", "Added cron (2)");

   if(! is_solaris) {
      cron env => root => delete => 0;
      my @envs = cron env => root => "list";
      ok($envs[0]->{name} eq "MYFOO", "env MYFOO");
      ok($envs[0]->{value} eq '"bar"', "env MYFOO value");
    
      cron delete => "root", 1;

      @crons = cron list => "root";
      ok(! $crons[1], "Removed 2nd cron");

      cron env => root => delete => 0;
   }

   cron delete => "root", 0;

   if(! is_solaris) {
      my @envs = cron env => root => "list";
      ok(scalar @envs == 0, "no envs anymore");
   }

   @crons = cron list => "root";
   ok(! $crons[0], "Removed 1st cron");

   done_testing();
};

