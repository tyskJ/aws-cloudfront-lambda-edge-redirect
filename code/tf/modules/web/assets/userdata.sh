#!/bin/bash
# システム更新 & Apache インストール
dnf update -y
dnf install -y httpd

# HTMLファイル作成
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EC2</title>
</head>
<body>
    <h1>EC2 Default Page!</h1>
</body>
</html>
EOF

cat <<EOF > /var/www/html/test1.html
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EC2</title>
</head>
<body>
    <h1>Web Server Test1 Page!</h1>
</body>
</html>
EOF

cat <<EOF > /var/www/html/test2.html
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EC2</title>
</head>
<body>
    <h1>Web Server Test2 Page!</h1>
</body>
</html>
EOF

# Alias設定ファイルを作成（welcome.confを直接編集せず、別のconfを作成）
cat <<EOF > /etc/httpd/conf.d/custom-alias.conf
Alias /test1/ /var/www/html/test1.html
Alias /test2/ /var/www/html/test2.html

<Directory "/var/www/html">
    Require all granted
</Directory>
EOF

# Apache を有効化 & 再起動
systemctl enable --now httpd
systemctl restart httpd

