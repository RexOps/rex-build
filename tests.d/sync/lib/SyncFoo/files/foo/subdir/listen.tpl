<% if($::eth0_ip) { %>
Listen <%= $::eth0_ip %>
<% } %>

<% if($::em0_ip) { %>
Listen <%= $::em0_ip %>
<% } %>

<% if($::xn0_ip) { %>
Listen <%= $::xn0_ip %>
<% } %>
