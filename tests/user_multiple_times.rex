# vim: set syn=perl:

use Rex -feature => '0.42';
use Rex::Commands::User;
use Data::Dumper;
use Test::More;

do "auth.conf";

desc "test";
task "test", group => "test", sub {

  if(!is_dir("/users")) {
    mkdir "/users";
  }

  my $new_gid = create_group "myfoogroup";
  ok($new_gid, "new group created");

  my $gid2 = create_group "myfoogroup";
  ok($new_gid == $gid2, "just modified group / no modificate");

  my $gid3 = create_group "myfoogroup", gid => 9999;
  ok($gid3 == 9999, "modified group with new gid");

  my $gid4 = create_group "myfoogroup", { gid => 8888 };
  ok($gid4 == 8888, "modified group with new gid (8888)");


  delete_group "myfoogroup";
  ok(! get_gid("myfoogroup"), "myfoogroup deleted");

  my $uid = create_user "duckbart";
  ok($uid, "user created");

  my $uid2 = create_user "duckbart";
  ok($uid == $uid2, "just modified user / no modification");

  my $uid3 = create_user "duckbart", uid => 9999;
  ok($uid3 == 9999, "user modified with new uid 9999");

  my $uid4 = create_user "duckbart", { uid => 8888 };
  ok($uid4 == 8888, "user modified with new uid 8888");

  delete_user "duckbart";
  ok(! get_uid("duckbart"), "duckbart deleted");
  ok(! get_gid("duckbart"), "duckbart group deleted");

  done_testing();
};
