#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:
   
package PkgBuilder;

use strict;
use warnings;


use Rex -feature => ['0.42', 'exit_status'];
use Rex::Helper::Path;
use YAML;
use IO::All;

require Exporter;
use base qw(Exporter);
use vars qw(@EXPORT);
@EXPORT = qw(
   run_or_die
   parse_template load_and_parse_yaml build_config
   config
   get_os_name get_os_release get_os_arch
   create_build_files
   doc_root
   get_build_env
   sync_time);

my $pid = $$;

my $config;


my %debian_version_map = (
   "7" => "wheezy",
   "6" => "squeeze",
);

my %ubuntu_version_map = (
   "1004" => "lucid",
   "1204" => "precise",
   "1210" => "quantal",
   "1304" => "raring",
   "1310" => "saucy",
   "1404" => "trusty",
);

sub config {
   if(defined $config) { return $config; }

   my $yaml = eval { local(@ARGV, $/) = ($ENV{HOME} . "/.build_config"); <>; };
   $yaml .= "\n";
   $config = Load($yaml);
}


sub parse_template {
   my ($file, @data) = @_;

   my $t = Rex::Template->new;
   my $content = io(get_file_path($file))->slurp;

   my $pre_parse = $t->parse($content, { @data });
   return $t->parse($pre_parse, { @data });
}

sub run_or_die {
   my ($cmd) = @_;

   my $output = run "LC_ALL=C $cmd";
   say $output;

   if($? != 0) {
      Rex::Logger::info("Error running command: $cmd", "error");
      die("Error running command: $cmd");
   }

   return $output;
}

sub load_and_parse_yaml {
   my ($content) = @_;

   my $pre_yaml = Load($content);
   $pre_yaml->{buildroot} = "";
   $pre_yaml->{sourceroot} = "";

   my $t = Rex::Template->new;

   return Load($t->parse($content, $pre_yaml));
}

sub build_config {
   my $config = shift;
   my $content;

   LOCAL {
      if(! is_file($config)) {
         Rex::Logger::info("Can't find build-file: $config", "error");
         die "Can't find build-file: $config";
      }

      $content = io($config)->slurp;    # io() always reads local files, but for better visibility it is in a LOCAL {} block.
      $content .= "\n"; # append a new line, because some editors just throw the last line away.

      mkdir ".build.$pid";
   };

   my $default_build_file = Load($content);
   my $double_parsed_build_file = load_and_parse_yaml($content);

   return ($default_build_file, $double_parsed_build_file);
}

sub get_os_name {

   my $op;

   LOCAL {
      if(! -d ".build.$pid") {
         mkdir ".build.$pid";
         return;
      }

      if(-f ".build.$pid/op.txt") {
         $op = cat ".build.$pid/op.txt";
         chomp $op;
      }
   };

   if(defined $op) { return $op; }

   if(is_file("/etc/fedora-release")) {
      $op = "Fedora";
   }


   $op ||= operating_system;
   chomp $op;
   io(".build.$pid/op.txt") < $op;

   return $op;
}

sub get_os_release {

   my $rel;

   LOCAL {
      if(! -d ".build.$pid") {
         mkdir ".build.$pid";
         return;
      }

      if(-f ".build.$pid/rel.txt") {
         $rel = cat ".build.$pid/rel.txt";
         chomp $rel;
      }
   };

   if(defined $rel) { return $rel; }

   if(lc(get_os_name) eq "ubuntu") {
      my $ver = operating_system_version();
      $rel = (exists $ubuntu_version_map{$ver} ? $ubuntu_version_map{$ver} : $ver);
   }
   elsif(lc(get_os_name) eq "debian") {
      my $ver = operating_system_version();
      $ver = substr($ver, 0, 1);
      $rel = (exists $debian_version_map{$ver} ? $debian_version_map{$ver} : $ver);
   }
   elsif(lc(get_os_name) eq "suse") {
      my ($raw_ver) = grep { m/^VERSION/ } split(/\n/, cat("/etc/SuSE-release"));
      chomp $raw_ver;
      my ($key, $_ver) = split(/ = /, $raw_ver);
      $rel = $_ver;
   }
   elsif(lc(get_os_name) eq "fedora") {
      $rel = operating_system_version();
   }
   else {
      $rel = substr(operating_system_version(), 0, 1);
   }

   io(".build.$pid/rel.txt") < $rel;

   return $rel;
}

sub get_os_arch {

   my $arch;

   LOCAL {
      if(! -d ".build.$pid") {
         mkdir ".build.$pid";
         return;
      }

      if(-f ".build.$pid/arch.txt") {
         $arch = cat ".build.$pid/arch.txt";
         chomp $arch;
      }
   };

   if(defined $arch) { return $arch; }

   $arch  = run "uname -i";

   if($arch eq "unknown") {
      $arch = run "uname -m";
   }

   chomp $arch;
   io(".build.$pid/arch.txt") < $arch;

   return $arch;
}

sub create_build_files {

   my $param = shift;

   my $op = get_os_name;
   my $rel = get_os_release;
   my $arch = get_os_arch;

   if(lc($op) eq "ubuntu" || lc($op) eq "debian") {

      if($arch eq "x86_64") { # rewrite arch for debian/ubuntu
         $arch = "amd64";
      }

      if($arch eq "i686") { # rewrite arch for debian/ubuntu
         $arch = "i386";
      }

   }

   my $upload_tarball_dir = config->{build}->{source_directory}->{lc($op)};
   my ($default_build_file, $double_parsed_build_file) = build_config($param->{build});
   my $pkg_name = $double_parsed_build_file->{name}->{lc($op)};

   mkdir "/root/build";
   mkdir config->{build}->{source_directory}->{lc($op)}
      if(exists config->{build}->{source_directory}->{lc($op)});

   if($op =~ m/centos|fedora|redhat|suse|mageia/i) {
      my $buildroot = "/tmp/build-$pkg_name-$pid";
      mkdir $buildroot;

      file "/root/build/$pkg_name.spec",
         content => parse_template("templates/spec.tpl", 
                           buildroot  => $buildroot,
                           os         => $op,
                           rel        => $rel,
                           arch       => $arch,
                           data       => $default_build_file,
                           sourceroot => $upload_tarball_dir, %{ $default_build_file }),
         owner   => "root",
         group   => "root",
         mode    => 640;

   }

   elsif($op =~ m/ubuntu/i || $op =~ m/debian/i) {

      my $buildroot = "/root/build/debian/$pkg_name";

      mkdir "/root/build/debian";
      file "/root/build/debian/control",
         content => parse_template("templates/control.tpl",
                           buildroot  => $buildroot,
                           os         => $op,
                           arch       => $arch,
                           rel        => $rel,
                           data       => $default_build_file,
                           sourceroot => $upload_tarball_dir, %{ $default_build_file }),
         owner   => "root",
         group   => "root",
         mode    => 640;

      file "/root/build/debian/changelog",
         content => parse_template("templates/changelog.tpl",
                           buildroot  => $buildroot,
                           os         => $op,
                           data       => $default_build_file,
                           sourceroot => $upload_tarball_dir, %{ $default_build_file }),
         owner   => "root",
         group   => "root",
         mode    => 640;

      file "/root/build/debian/rules",
         content => parse_template("templates/rules.tpl",
                           buildroot  => $buildroot,
                           os         => $op,
                           data       => $default_build_file,
                           sourceroot => $upload_tarball_dir, %{ $default_build_file }),
         owner   => "root",
         group   => "root",
         mode    => 640;

      file "/root/build/debian/configure.sh",
         content => parse_template("templates/configure.sh.tpl",
                           buildroot  => $buildroot,
                           os         => $op,
                           data       => $default_build_file,
                           sourceroot => $upload_tarball_dir, %{ $default_build_file }),
         owner   => "root",
         group   => "root",
         mode    => 755;

      file "/root/build/debian/make.sh",
         content => parse_template("templates/make.sh.tpl",
                           buildroot  => $buildroot,
                           os         => $op,
                           data       => $default_build_file,
                           sourceroot => $upload_tarball_dir, %{ $default_build_file }),
         owner   => "root",
         group   => "root",
         mode    => 755;

      file "/root/build/debian/install.sh",
         content => parse_template("templates/install.sh.tpl",
                           buildroot  => $buildroot,
                           os         => $op,
                           data       => $default_build_file,
                           sourceroot => $upload_tarball_dir, %{ $default_build_file }),
         owner   => "root",
         group   => "root",
         mode    => 755;

      file "/root/build/debian/clean.sh",
         content => parse_template("templates/clean.sh.tpl",
                           buildroot  => $buildroot,
                           os         => $op,
                           data       => $default_build_file,
                           sourceroot => $upload_tarball_dir, %{ $default_build_file }),
         owner   => "root",
         group   => "root",
         mode    => 755;

      file "/root/build/debian/compat", content => "7\n";
   }

}

sub sync_time {
   my $op = get_os_name;


   if($op =~ m/ubuntu/i) {
      service ntp => "stop";
   }

   for (1..10) {
      Rex::Logger::info("Syncing time...");

      run "ntpdate pool.ntp.org";
      if($? == 0) {
         return;
      }
      sleep 1;
   }

   Rex::Logger::info("Failed syning time... ", "warn");
#   die "Error syning time.";
}

sub doc_root {
   my $env = get_build_env();
   return config()->{repo}->{doc_root}->{$env};
}

sub get_build_env {
   my $env = $ENV{BUILD_ENV} || "live";

   if(-f "/nightly" && ! exists $ENV{BUILD_ENV}) {
      $env = "nightly";
   }

   if(-f "/prelive" && ! exists $ENV{BUILD_ENV}) {
      $env = "prelive";
   }

   if(-f "/live" && ! exists $ENV{BUILD_ENV}) {
      $env = "live";
   }

   return $env;
}

1;
