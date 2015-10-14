# vim: set syn=perl:
use Rex -feature => '0.42';
use Test::More;

do "auth.conf";

task test => group => test => sub {

  if(is_linux) {

    firewall "open-port-81",
      action => "accept",
      port   => 81,
      on_change => sub {
        my($type) = @_;
        is($type, "created", "created firewall rule for port 81");
      };
      
    run "iptables-save | grep 'port 81'";
    is($?, 0, "found port 81 rule inside iptables-save");

    firewall "remove-open-port-81",
      ensure => "absent",
      action => "accept",
      port   => 81,
      on_change => sub {
        my($type) = @_;
        is($type, "removed", "removed firewall rule for port 81");
      };

    run "iptables-save | grep 'port 81'";
    is($?, 1, "NOT found port 81 rule inside iptables-save");

    firewall "open-port-82-for-1.2.3.4",
      action => "accept",
      port   => 82,
      source => "1.2.3.4";
      
    run "iptables-save | grep 'port 82' | grep 's 1.2.3.4'";
    is($?, 0, "found port 82 and source 1.2.3.4 rule inside iptables-save");

    firewall "open-port-82-for-1.2.3.4",
      ensure => "absent",
      action => "accept",
      port   => 82,
      source => "1.2.3.4";
      
    run "iptables-save | grep 'port 82' | grep 's 1.2.3.4'";
    is($?, 1, "NOT found port 82 and source 1.2.3.4 rule inside iptables-save");

  }
  else {
    ok(1==1, "no support for OS " . operating_system);
  }

  done_testing();

};
