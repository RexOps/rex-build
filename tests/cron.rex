# vim: set syn=perl:

use Rex -feature => '0.42';
use Rex::Commands::Cron;

use Test::More;

do "auth.conf";

task test => group => test => sub {
  run "touch j; crontab j; rm j";

  cron add => "root", {
    minute => "5,10,15",
    hour  => "1,3,5,7",
    command => "/bin/ls /",
  };

  cron add => "root", {
    minute => "5,10,15",
    hour  => "1,3,5,7",
    command => "/bin/ls /",
  };


  my @crons = cron list => "root";
  #print Dumper(@crons);
  ok($crons[0]->{"command"} eq "/bin/ls /", "Added cron");

  ok(scalar(@crons) == 1, "no duplicated cron job");

  my $env_id = 0;

  if(! is_solaris) {
    cron env => root => add => {
      MYVAR => "foo",
      MYFOO => "bar",
    };

    my @envs = cron env => root => "list";

    my $i = 0;
    for my $e (@envs) {
      if($e->{name} eq "MYVAR") { $env_id = $i; last; }
      $i++;
    }

    my ($e1) = grep { $_->{name} eq "MYVAR" } @envs;
    my ($e2) = grep { $_->{name} eq "MYFOO" } @envs;
 
    ok($e1->{name} eq "MYVAR", "env MYVAR");
    ok($e1->{value} eq '"foo"', "env MYVAR value");
    ok($e2->{name} eq "MYFOO", "env MYFOO");
    ok($e2->{value} eq '"bar"', "env MYFOO value");
  }

  cron add => "root", {
    minute => "5,10,15",
    hour  => "1,3,5,7",
    command => "uptime",
  };

  @crons = cron list => "root";
  ok($crons[1]->{"command"} eq "uptime", "Added cron (2)");

  if(! is_solaris) {
    cron env => root => delete => $env_id;
    my @envs = cron env => root => "list";
    my ($e1) = grep { $_->{name} eq "MYVAR" } @envs;
    my ($e2) = grep { $_->{name} eq "MYFOO" } @envs;
 
    ok($e2->{name} eq "MYFOO", "env MYFOO");
    ok($e2->{value} eq '"bar"', "env MYFOO value");
    ok(!$e1, "env MYVAR delete.");
   
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

