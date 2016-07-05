# vim: set syn=perl:
use Rex -feature => 0.42;
use Rex::Commands::Rsync;
use Test::More;
use Rex::Commands::Gather;
use Rex::Transaction;

do "auth.conf";

timeout 15;

task "test", group => "test", sub {

  mkdir "/home/rsync_user/etc2", owner => "rsync_user";
  my $ok = 0;
  my $count = 0;
  
  while($ok == 0) {
    if($count > 10) {
      last;
    }
    
    eval {
      local $SIG{ALRM} = sub {
        $count++;
        sleep 1;
        next;
      };

      alarm 30;
      sync "files/etc/", "/home/rsync_user/etc2/";
      alarm 0;
      
      $ok = 1;
    };
  }

  my %stat = stat "/home/rsync_user/etc2/my.cnf";

  if( Rex::is_sudo ) {
    ok($stat{uid} != 6000, "/home/rsync_user/etc/my.cnf owner");
    ok($stat{gid} != 6000, "/home/rsync_user/etc2/my.cnf group");
  }
  else {
    ok($stat{uid} == 6000, "/home/rsync_user/etc/my.cnf owner");
    ok($stat{gid} == 6000, "/home/rsync_user/etc2/my.cnf group");
  }

  done_testing();
};

auth for => test => user => "rsync_user", password => "rsync.pw", sudo_password => "rsync.pw", pass_auth => TRUE;

