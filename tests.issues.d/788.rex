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

  my $o = Foo788->new(server => $t_server);
  my $u = $o->get_user;

  is($u, "testu", "Found testuser. run_task connects to the right server/user.");  
  
  done_testing();
  
};

1;
