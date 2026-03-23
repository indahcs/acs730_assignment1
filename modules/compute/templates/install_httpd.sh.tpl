#!/bin/bash
# modules/compute/templates/install_httpd.sh.tpl

yum update -y
yum install -y httpd

cat <<EOF > /var/www/html/index.html
<html>
  <body>
    <h1>Name: ${owner}</h1>
    <p>Environment: ${environment}</p>
    <p>Private IP: $(hostname -I)</p>
  </body>
</html>
EOF

systemctl start httpd
systemctl enable httpd