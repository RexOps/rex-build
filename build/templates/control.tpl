Source: <%= $data->{name}->{lc($os)} %>
Section: <%= $data->{group}->{lc($os)} %>
Priority: <%= $data->{priority} %>
Maintainer: <%= $data->{maintainer} %>
Build-Depends: <%= join(",\n         ", @{ $data->{requires}->{lc($os)}->{build} || $data->{requires}->{lc($os)}->{$rel}->{build} }) %>
Standards-Version: 3.9.1
Homepage: <%= $data->{homepage} %>

Package: <%= $data->{name}->{lc($os)} %>
Architecture: <%= $arch %>
Depends: <%= join(",\n         ", @{ $data->{requires}->{lc($os)}->{runtime} || $data->{requires}->{lc($os)}->{$rel}->{runtime} }) %>
Description: <%= $data->{summary} %>
 <%= join("\n ", split(/\n/, $data->{description}) ) %>
