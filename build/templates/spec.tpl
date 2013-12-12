Name:           <%= $data->{name}->{lc($os)} %>
Version:        <%= $data->{version} %>
Release:        <%= $data->{release} %>
Summary:        <%= $data->{summary} %>

Group:          <%= $data->{group}->{lc($os)} %>
License:        <%= $data->{license} %>
Source:         <%= $data->{source} %>
BuildRoot:      <%= $buildroot %>

<% for my $req (@{ $data->{requires}->{lc($os)}->{build} }) { %>
BuildRequires:  <%= $req %><% } %>

<% if(exists $data->{requires}->{lc($os)}->{runtime}) { %>
<% for my $req (@{ $data->{requires}->{lc($os)}->{runtime} }) { %>
Requires:  <%= $req %><% } %><% } %>

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
<% for my $doc (@{ $data->{files}->{doc} }) { %>
%doc <%= $doc %><% } %>

<% for my $file (@{ $data->{files}->{package} }) { %>
<%= $file %><% } %>


