#!/usr/bin/env perl

use YAML;
use Data::Dumper;
use Cwd 'getcwd';

$ENV{PATH} = getcwd() . ":" . $ENV{PATH};
system "prove --formatter TAP::Formatter::JUnit --ext rex -e rex-test";
