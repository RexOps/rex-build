#!/bin/bash


apt-ftparchive generate -c=aptftp.conf aptgenerate.conf 
apt-ftparchive release -c=aptftp.conf dists/<%= $::dist %> >dists/<%= $::dist %>/Release

rm -f dists/<%= $::dist %>/Release.gpg

gpg -u EB1E3473 -bao dists/<%= $::dist %>/Release.gpg dists/<%= $::dist %>/Release


