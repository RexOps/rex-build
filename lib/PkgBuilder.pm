#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:
   
package PkgBuilder;

use strict;
use warnings;


use Rex -base;
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
   get_os_name get_os_release get_os_arch);

my $pid = $$;

my $config;

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

   my $output = run $cmd;
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

   $op = operating_system;
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

   $rel = substr(operating_system_version(), 0, 1);
   chomp $rel;
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
   chomp $arch;
   io(".build.$pid/arch.txt") < $arch;

   return $arch;
}

1;
