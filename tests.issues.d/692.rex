# vim: set syn=perl:
use Test::More;
use Rex::Commands::User;

do "auth.conf";

use Rex::Transaction;

task test => group => test => sub {

  # prepare test
  #

  transaction {    # make a transaction for not forking

    on_rollback {
        fail("Rollback triggered, please investigate");
        done_testing();
    };

    create_group "test692";

    my $groups = ["test692"];
    push @$groups, 'wheel' if is_freebsd();

    account "test692",
      home        => "/home/test692",
      uid         => 12000,
      groups      => $groups,
      password    => "test",
      ensure      => "present",
      create_home => TRUE;

    my $sudoers_file = is_freebsd() ? "/usr/local/etc/sudoers" : "/etc/sudoers";

    append_if_no_such_line $sudoers_file, "test692 ALL=(ALL:ALL) ALL";
    delete_lines_matching $sudoers_file, "Defaults targetpw";
    delete_lines_matching $sudoers_file, qr{Defaults\s+requiretty};

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
