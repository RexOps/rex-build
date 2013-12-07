APT::FTPArchive::Release {
  Origin "Rex";
  Label "Rex";
  Suite "<%= $dist %>";
  Codename "<%= $dist %>";
  Architectures "i386 amd64";
  Components "rex";
  Description "Rex Repository";
};
