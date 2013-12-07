Dir::ArchiveDir ".";
Dir::CacheDir ".";
TreeDefault::Directory "pool/<%= $dist %>/";
TreeDefault::SrcDirectory "pool/<%= $dist %>/";
Default::Packages::Extensions ".deb";
Default::Packages::Compress ". gzip bzip2";
Default::Sources::Compress "gzip bzip2";
Default::Contents::Compress "gzip bzip2";

BinDirectory "dists/<%= $dist %>/rex/binary-i386" {
  Packages "dists/<%= $dist %>/rex/binary-i386/Packages";
  Contents "dists/<%= $dist %>/Contents-i386";
};

BinDirectory "dists/<%= $dist %>/rex/binary-amd64" {
  Packages "dists/<%= $dist %>/rex/binary-amd64/Packages";
  Contents "dists/<%= $dist %>/Contents-amd64";
};

Tree "dists/<%= $dist %>" {
  Sections "rex";
  Architectures "i386 amd64";
};
