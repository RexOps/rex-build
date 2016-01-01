# vim: set syn=perl:
use Test::More;

do 'auth.conf';

use Rex -feature => ['1.3'];

use lib "tests.issues.d/lib";

use Foo788;
use Server788;

my $t_server = Server788->new(name => $ENV{HTEST}, auth => { user => "testu", password => "testu", sudo => FALSE });

task test => group => test => sub {
  
  account "testu", password => "testu";

  if(is_freebsd) {
    install "sudo";
  
    file "/usr/local/etc/sudoers",
      content =>
      "Defaults set_home, always_set_home\n\%$user	ALL=(ALL:ALL) ALL\nrsync_user	ALL=(ALL:ALL) ALL\nrsync_user ALL=(ALL:ALL) NOPASSWD: /usr/bin/rsync\n",
      owner => "root",
      mode  => 440;
    append_if_no_such_line "/usr/local/etc/sudoers", "testu ALL=(ALL:ALL) ALL";
  }
  else {
    append_if_no_such_line "/etc/sudoers", "testu ALL=(ALL:ALL) ALL";
  }

  my $o = Foo788->new(server => $t_server);
  my $u = $o->get_user;

  is($u, "testu", "Found testuser. run_task connects to the right server/user.");  
  
  done_testing();
  
};

1;
