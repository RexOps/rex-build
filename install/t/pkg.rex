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

    #say Dumper(config->{repo}->{add}->{get_build_env()}->{lc($op)}->{$ver}->{$arch});

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

    #say Dumper(config->{repo}->{add}->{get_build_env()}->{lc($op)});
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
    install $ENV{TEST_PACKAGE};
    $ok = 1;
  };
  ok($ok == 1, "$ENV{TEST_PACKAGE} installed");

  if($ENV{TEST_PACKAGE} eq "rex") {
    my $out = run "rex -v";
    ok($? == 0, "run rex");
    my ($name, $version) = split(/ /, $out);
    ok($version =~ m/\d+\.\d+\.\d+/, "got version ($version)");
    ok($version eq get_version_to_install(), "got correct version");
  }

  if($ENV{TEST_PACKAGE} eq "rex-jobcontrol") {
    mkdir "/etc/rex";
    require Mojo::UserAgent;
    my $ua = Mojo::UserAgent->new;
    my $content = $ua->get("https://raw.githubusercontent.com/RexOps/rex-jobcontrol/master/jobcontrol.conf")->res->body;
    file "/etc/rex/jobcontrol.conf", content => $content;
    my $out = run "rex_job_control jobcontrol version";
    ok($? == 0, "run rex_job_control");
    my ($version) = ($out =~ m/\((\d+\.\d+\.\d+)\)/);
    ok($version =~ m/\d+\.\d+\.\d+/, "got version ($version)");
    ok($version eq get_version_to_install(), "got correct version");
  }


  done_testing();
};
