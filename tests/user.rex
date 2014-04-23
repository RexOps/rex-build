# vim: set syn=perl:

use Rex -feature => '0.42';
use Rex::Commands::User;
use Data::Dumper;
use Test::More;

do "auth.conf";

desc "test";
task "test",
  group => "test",
  sub {

  if ( !is_dir("/users") ) {
    mkdir "/users";
  }

  create_group "users";
  ok( get_gid("users") > 1, "created group users" );

  my %user = get_user("root");
  ok( get_uid("root") == 0,  "get root" );
  ok( $user{name} eq "root", "get root name" );

  my $new_uid = create_user "trak",
    {
    home     => '/users/trak',
    comment  => 'Trak User',
    groups   => ['users'],
    password => 'hello2',
    };

  #say "New UID: $new_uid";
  ok( defined $new_uid, "new user created" );

  ok( is_dir('/users/trak'), "homedirectory created" );

  delete_user "trak", { delete_home => 1 };
  ok( !get_uid("trak"),       "user deleted" );
  ok( !is_dir('/users/trak'), "homedirectory deleted." );

  my $root_group = "root";
  if ( is_freebsd || is_netbsd || is_openbsd ) {
    $root_group = "wheel";
  }

  ok( get_gid($root_group) == 0, "get root group id" );

  my %group = get_group($root_group);
  ok( $group{name} eq $root_group, "get root group name" );

  my $new_gid = create_group "testgr";
  ok( $new_gid, "new group created" );

  delete_group "testgr";
  ok( !get_gid("testgr"), "group deleted" );

  my @user_list = user_list();
  ok( grep( /^nobody$/, @user_list ), "found user nobody" );

  my @group_list = user_groups("nobody");
  ok( grep( /^nobody$/, @group_list ), "found group nobody" );

  my $group_list_ref = user_groups("nobody");
  ok( ref($group_list_ref) eq "ARRAY", "user_groups returns arrayRef" );
  ok( grep( /^nobody$/, @{$group_list_ref} ), "found group nobody in ref" );

  my $new_uid2 = create_user "baz",
    home           => '/tmp',
    no_create_home => TRUE;

  ok( defined $new_uid2, "baz ($new_uid2) created" );

  my %baz_info = get_user("baz");
  ok( $baz_info{home} eq "/tmp", "baz home is /tmp" );

  delete_user "baz";
  ok( !get_uid("baz"), "baz deleted" );
  ok( is_dir("/tmp"),  "home of baz not deleted" );

  my $new_uid3 = create_user "bar",
    home    => "/users/bar",
    ssh_key => "blahblah";

  ok( defined $new_uid3, "user bar ($new_uid3) created" );
  ok(
    is_file("/users/bar/.ssh/authorized_keys"),
    "user bar have an authorized_keys files"
  );

  my @content = cat("/users/bar/.ssh/authorized_keys");
  chomp @content;
  ok( $content[0] eq "blahblah", "content of authorized_keys file is ok" );

  delete_user "bar", delete_home => TRUE;
  ok( !get_uid("bar"),       "user bar deleted" );
  ok( !is_dir("/users/bar"), "home of bar deleted" );

  my $new_uid4 = create_user "kuh",
    no_create_home => TRUE,
    home           => "/users/kuh",
    ssh_key        => "rumsbums";

  ok( defined $new_uid4,     "created user kuh ($new_uid4)" );
  ok( !is_dir("/users/kuh"), "kuh doesn't have a home" );

  delete_user "kuh";

  ok( !get_uid("kuh"), "user kuh deleted" );

  my $new_uid5 = create_user "muh",
    home           => "/users/muh",
    no_create_home => FALSE;

  ok( defined $new_uid5,    "user muh ($new_uid5) created" );
  ok( is_dir("/users/muh"), "muh does have a home" );

  delete_user "muh", delete_home => TRUE;

  ok( !get_uid("muh"),       "user muh deleted" );
  ok( !is_dir("/users/muh"), "home of muh deleted" );

  my $new_uid6 = create_user "horse",
    home           => "/users/horse",
    no_create_home => FALSE,
    ssh_key        => "ramba";

  ok( defined $new_uid6,      "user horse ($new_uid6) created" );
  ok( is_dir("/users/horse"), "horse does have a home" );
  ok(
    is_file("/users/horse/.ssh/authorized_keys"),
    "horse does have an authorized_keys"
  );

  delete_user "horse", delete_home => TRUE;

  my $new_uid7 = create_user "apple",
    home        => "/users/apple",
    create_home => TRUE,
    ssh_key     => "apple";

  ok( defined $new_uid7,      "user apple ($new_uid7) created" );
  ok( is_dir("/users/apple"), "apple does have a home" );
  ok(
    is_file("/users/apple/.ssh/authorized_keys"),
    "apple does have an authorized_keys"
  );

  my $new_uid8 = create_user "banana",
    home        => "/users/banana",
    create_home => FALSE;

  ok( defined $new_uid7,        "user banana ($new_uid8) created" );
  ok( !is_dir("/users/banana"), "banana does NOT have a home" );

  ok( !get_uid("horse"),       "user horse deleted" );
  ok( !is_dir("/users/horse"), "home of horse deleted" );

  done_testing();
  };
