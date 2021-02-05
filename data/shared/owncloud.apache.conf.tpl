ProxyRequests off
ProxyPass /owncloud http://127.0.0.1:<@http_port@>
ProxyPassReverse /owncloud http://127.0.0.1:<@http_port@>
