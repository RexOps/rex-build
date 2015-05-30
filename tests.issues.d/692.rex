# vim: set syn=perl:
use Test::More;
use Rex::Commands::User;

do "auth.conf";

use Rex::Transaction;

task test => group => test => sub {

  # prepare test
  #

  transaction {    # make a transaction for not forking
    create_group "test692";

    account "test692",
      home        => "/home/test692",
      uid         => 12000,
      groups      => ["test692"],
      password    => "test",
      ensure      => "present",
      create_home => TRUE;

    append_if_no_such_line "/etc/sudoers", "test692 ALL=(ALL:ALL) ALL";

    do_task "auth_test";
    done_testing();
  };
};

task auth_test => group => test => sub {
  my $id = run "id";
  like( $id, qr/uid=0/, "got uid=0 for sudo task" );
};

auth
  for           => "auth_test",
  sudo          => TRUE,
  user          => "test692",
  password      => "test",
  sudo_password => "test";

1;
