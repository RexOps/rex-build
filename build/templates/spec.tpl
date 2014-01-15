Name:           <%= $data->{name}->{lc($os)} %>
Version:        <%= $data->{pkgversion}->{lc($os)} || $data->{version} %>
Release:        <%= $data->{release} %>
Summary:        <%= $data->{summary} %>

Group:          <%= $data->{group}->{lc($os)} %>
License:        <%= $data->{license} %>
Source:         <%= $data->{source} %>
BuildRoot:      <%= $buildroot %>

<% if(exists $data->{no_auto_scan}) { %>
AutoReqProv: no
<% } %>

<% if(exists $data->{requires}->{lc($os)}->{$rel}->{build}) { %>

<% for my $req (@{ $data->{requires}->{lc($os)}->{$rel}->{build} }) { %>
BuildRequires:  <%= $req %><% } %>

<% } %>

<% if(exists $data->{requires}->{lc($os)}->{$rel}->{runtime}) { %>

<% for my $req (@{ $data->{requires}->{lc($os)}->{$rel}->{runtime} }) { %>
Requires:  <%= $req %><% } %>

<% } %>

<% if(exists $data->{requires}->{lc($os)}->{$rel}->{$arch}->{build}) { %>

<% for my $req (@{ $data->{requires}->{lc($os)}->{$rel}->{$arch}->{build} }) { %>
BuildRequires:  <%= $req %><% } %>

<% } %>

<% if(exists $data->{requires}->{lc($os)}->{$rel}->{$arch}->{runtime}) { %>

<% for my $req (@{ $data->{requires}->{lc($os)}->{$rel}->{$arch}->{runtime} }) { %>
Requires:  <%= $req %><% } %>

<% } %>


%description
<%= $data->{description} %>


%prep
<%= $data->{configure} %>

%build
<%= $data->{make} %>

%install
<%= $data->{install} %>


%clean
<%= $data->{clean} %>

%files
%defattr(-,root,root,-)
<% if(! exists $data->{files}->{lc($os)}) { %>
<% for my $doc (@{ $data->{files}->{doc} }) { %>
%doc <%= $doc %><% } %>
<% } %>

<% for my $doc (@{ $data->{files}->{lc($os)}->{doc} }) { %>
%doc <%= $doc %><% } %>

<% if(! exists $data->{files}->{lc($os)}) { %>
<% for my $file (@{ $data->{files}->{package} }) { %>
<%= $file %><% } %>
<% } %>

<% for my $file (@{ $data->{files}->{lc($os)}->{package} }) { %>
<%= $file %><% } %>

<% if(exists $data->{pre}) { %>
%pre
<%= $data->{pre} %>
<% } %>

<% if(exists $data->{post}) { %>
%post
<%= $data->{post} %>
<% } %>

