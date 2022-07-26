%{ if length(servers) != 0 ~}
[server]
# the consul / nomad servers
%{ for host, ip in servers ~}
${host} ansible_host=${ip}
%{ endfor ~}

[server:vars]
is_server=true
%{ endif ~}

%{ if length(clients) != 0 ~}
[client]
# the consul / nomad clients
%{ for host, ip in clients ~}
${host} ansible_host=${ip}
%{ endfor ~}

[client:vars]
is_server=false
%{ endif ~}

