# vim: set syn=perl:
use Test::More;

do 'auth.conf';

use Rex::Transaction;

task test => group => test => sub {
  transaction {
    on_rollback {
      my $exception = shift;
      like ($exception, qr{Passing error message to rollback}, 'Passed info to rollback');
      done_testing();
    };

    run 'this command should fail';
    if($? != 0) { die('Passing error message to rollback'); }
  };
};

1;
