Source: <%= $data->{name} %>
Section: <%= $data->{group}->{lc($os)} %>
Priority: <%= $data->{priority} %>
Maintainer: <%= $data->{maintainer} %>
Build-Depends: <%= join(",\n         ", @{ $data->{requires}->{lc($os)}->{build} }) %>
Standards-Version: 3.9.1
Homepage: <%= $data->{homepage} %>

Package: <%= $data->{name} %>
Architecture: <%= $data->{arch}->{lc($os)} %>
Depends: <%= join(",\n         ", @{ $data->{requires}->{lc($os)}->{runtime} }) %>
Description: <%= $data->{summary} %>
 <%= join("\n ", split(/\n/, $data->{description}) ) %>
