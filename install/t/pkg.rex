# vim: set syn=perl:

use Rex -feature => '0.42';
use lib "../lib";
use PkgBuilder;
use Test::More;
use Data::Dumper;

do "../auth.conf";

task test => group => test => sub {
  my $ok;

  my $op  = get_os_name;
  my $arch = get_os_arch;
  my $ver  = get_os_release;

  if(exists config->{repo}->{add}->{get_build_env()}->{lc($op)}
    && exists config->{repo}->{add}->{get_build_env()}->{lc($op)}->{$ver}
    && exists config->{repo}->{add}->{get_build_env()}->{lc($op)}->{$ver}->{$arch}) {

    say Dumper(config->{repo}->{add}->{get_build_env()}->{lc($op)}->{$ver}->{$arch});

    if(is_mageia) {
      my $url = config->{repo}->{add}->{get_build_env()}->{lc($op)}->{$ver}->{$arch}->{url};
      my $line = "rex $url {\n  key-ids: 16547F8C\n}\n";
      cp "/etc/urpmi/urpmi.cfg", "/etc/urpmi/urpmi.cfg.rex.bak";
      append_if_no_such_line "/etc/urpmi/urpmi.cfg",
        line  => $line,
        regexp => qr/rex $url/;
      $ok = 1;
    }
    else {

      eval {
        repository add => "rex", (distro => $ver), %{ config->{repo}->{add}->{get_build_env()}->{lc($op)}->{$ver}->{$arch} };
        $ok = 1;
        1;
      } or do {
        eval { repository remove => "rex"; };
      };

    }

  }
  else {

    say Dumper(config->{repo}->{add}->{get_build_env()}->{lc($op)});
    eval {
      repository add => "rex", (distro => $ver), %{ config->{repo}->{add}->{get_build_env()}->{lc($op)} }
        if(exists config->{repo}->{add}->{get_build_env()}->{lc($op)});
      $ok = 1;
    } or do {
      eval { repository remove => "rex"; };
    };

  }

  ok($ok == 1, "repository added");

  $ok = 1;

  if(is_debian) {
    run "wget -O - http://rex.linux-files.org/DPKG-GPG-KEY-REXIFY-REPO | apt-key add -";
  }
  else {
    if(lc($op) eq "centos" && $ver =~ m/^5/) {
      run "rpm --import http://rex.linux-files.org/RPM-GPG-KEY-REXIFY-REPO.CENTOS5";
    }
    else {
      run "rpm --import http://rex.linux-files.org/RPM-GPG-KEY-REXIFY-REPO.CENTOS6";
    }
  }

  if($? != 0) {
    $ok = 0;
  }
  ok($ok == 1, "added gpg key");

  eval {
    $ok = 0;
    update_package_db();
    $ok = 1;
  };
  ok($ok == 1, "update package db");

  eval {
    $ok = 0;
    install "rex";
    $ok = 1;
  };
  ok($ok == 1, "rex installed");

  my $out = run "rex -v";
  ok($? == 0, "run rex");
  my ($name, $version) = split(/ /, $out);
  ok($version =~ m/\d+\.\d+\.\d+/, "got version ($version)");
  ok($version eq get_version_to_install(), "got correct version");

  done_testing();
};
