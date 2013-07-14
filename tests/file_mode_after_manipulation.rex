# vim: set syn=perl:
use Rex -feature => 0.42;
use Test::More;

user $ENV{REXUSER};
password $ENV{REXPASS};
pass_auth;

if(exists $ENV{use_sudo}) {
   sudo_password $ENV{REXPASS};
   sudo -on;
}

group test => $ENV{HTEST};

desc "test";
task "test", group => "test", sub {

   my $file = "/tmp/mode_file.txt";

   file $file, mode => 440, owner => "root", group => "root";

   my %pre_stat = stat $file;

   append_if_no_such_line $file, "jan  ALL=(ALL:ALL) ALL", qr{^jan};

   my $sudoers = cat $file;
   ok($sudoers =~ m/^jan/gm, "found jan in sudoers");

   my %post_stat = stat $file;

   ok($pre_stat{mode}  == $post_stat{mode}, "mode after append_if_no_such_line is the same");
   ok($pre_stat{uid} == $post_stat{uid}, "owner after append_if_no_such_line is the same");
   ok($pre_stat{gid} == $post_stat{gid}, "group after append_if_no_such_line is the same");

   delete_lines_matching $file => qr{^jan};

   %post_stat = ();
   %post_stat = stat $file;

   ok($pre_stat{mode}  == $post_stat{mode}, "mode after delete_lines_matching is the same");
   ok($pre_stat{uid} == $post_stat{uid}, "owner after delete_lines_matching is the same");
   ok($pre_stat{gid} == $post_stat{gid}, "group after delete_lines_matching is the same");

   done_testing();

};

