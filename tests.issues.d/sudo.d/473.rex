# vim: set syn=perl:
use Rex -feature => '0.42';
use Test::More;
use Rex::Commands::Fs;

do "auth.conf";

task test => group => test => sub {

  download "/root/issue473.txt", "issue473.txt";
  LOCAL {
    my $content = cat "issue473.txt";
    ok($content =~ m/issue473/, "download root restricted file from root restricted directory");
  };

  done_testing();
};
