#!/bin/bash

# Update and upgrade system packages
echo "=== Starting System Updates ==="
apt-get update && apt-get upgrade -y
if [ $? -ne 0 ]; then
    echo "ERROR: System update failed"
    exit 1
fi
echo "System updates completed successfully"

# Install required packages
echo "=== Installing Required Packages ==="
apt-get install -y apache2 mysql-client php php-mysql php-curl php-gd php-intl php-mbstring \
                   php-soap php-xml php-xmlrpc php-zip php-redis git
if [ $? -ne 0 ]; then
    echo "ERROR: Package installation failed"
    exit 1
fi
echo "Package installation completed successfully"

# sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/wp-content|' /etc/apache2/sites-enabled/000-default.conf
rm -f /var/www/html/index.html
systemctl restart apache2


# Download and configure WordPress
echo "=== Downloading WordPress ==="
wget --no-check-certificate -O /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz
if [ $? -ne 0 ]; then
    echo "ERROR: WordPress download failed"
    exit 1
fi

echo "=== Extracting WordPress ==="
tar -xzf /tmp/wordpress.tar.gz -C /var/www/html/
rm -f /tmp/wordpress.tar.gz
#mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
#sudo chown -R www-data:www-data /var/www/html/wordpress
#sudo chmod -R 755 /var/www/html/wordpress
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

# Install WP-CLI
echo "=== Installing WP-CLI ==="
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
echo "=== Creating wp-config.php ==="
cat > /var/www/html/wordpress/wp-config.php <<EOL
<?php
define( 'DB_NAME', '${db_name}' );
define( 'DB_USER', '${db_user}' );
define( 'DB_PASSWORD', '${db_password}' );
define( 'DB_HOST', '${db_host}' );
define( 'DB_CHARSET', 'utf8mb4' );
define( 'DB_COLLATE', '' );
 
define( 'MYSQL_CLIENT_FLAGS', MYSQLI_CLIENT_SSL );
define( 'WP_ALLOW_REPAIR', true );
 
define( 'WP_PERSISTENT_DB', true );
define( 'WP_DB_CONNECT_TIMEOUT', 30 );
 
define( 'WP_REDIS_HOST', '${redis_host}' );
define( 'WP_REDIS_PORT', ${redis_port} );
define( 'WP_CACHE', true );
 
define( 'WP_MEMORY_LIMIT', '256M' );
define( 'WP_MAX_MEMORY_LIMIT', '512M' );
 
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
define( 'WP_DEBUG_DISPLAY', false );
@ini_set( 'display_errors', 0 );





\$table_prefix = 'wp_';

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}
require_once ABSPATH . 'wp-settings.php';
EOL
 
chown -R www-data:www-data /var/www/html/wordpress/wp-config.php
chmod -R 644 /var/www/html/wordpress/wp-config.php

cat > /etc/apache2/sites-enabled/wordpress.conf <<EOL
<VirtualHost *:80>
  DocumentRoot /var/www/html/wordpress
  <Directory /var/www/html/wordpress>
    Options FollowSymLinks
    AllowOverride All
    Require all granted
  </Directory>
</VirtualHost>
EOL

# Install WordPress
echo "=== Installing WordPress ==="
cd /var/www/html/wordpress
wp core install --url="http://${site_url}" \
                --title="WordPress Site" \
                --admin_user="admin" \
                --admin_password="${db_password}" \
                --admin_email="admin@example.com" \
                --skip-email \
                --path="/var/www/html/wordpress" \
                --allow-root

# Create new ReadOnly role
echo "=== Creating ReadOnly Role ==="
wp role create readonly "Read Only" --allow-root

# Add comprehensive read capabilities to the ReadOnly role
READONLY_CAPABILITIES=(
    # Basic reading capabilities
    "read"
    "read_private_posts"
    "read_private_pages"
    "read_others_posts"
    "read_others_pages"
    
    # Comment related
    "read_comments"
    
    # User related
    "list_users"
    
    # Media related
    "read_media"
    "read_private_media"
    
    # Term/taxonomy related
    "read_terms"
    "read_taxonomies"
    
    # View capabilities
    "view_site_health_checks"
    "view_admin_dashboard"
    
    # Plugin/Theme viewing
    "read_plugins"
    "read_themes"
    
    # Basic admin access
    "access_admin"
    "read_revisions"
    
    # Analytics and reporting
    "view_stats"
    "view_reports"
    
    # Custom post type reading
    "read_private_products"
    "read_others_products"
    "browse_products"
    
    # Menu viewing
    "read_menus"
    
    # SEO plugin related (if using)
    "view_seo_stats"
    "read_seo_data"
)

# Add all capabilities to the readonly role
echo "=== Adding Capabilities to ReadOnly Role ==="
for cap in "$${READONLY_CAPABILITIES[@]}"; do
    wp role add-cap readonly "$cap" --allow-root
done

# Create read-only user with the new role
echo "=== Creating Read-Only User ==="
wp user create "${ro_username}" "${ro_username}@example.com" \
    --role=readonly \
    --user_pass="${ro_password}" \
    --allow-root

# Verify role capabilities
echo "=== Verifying ReadOnly Role Capabilities ==="
wp role list-caps readonly --allow-root
#Change Theme
wp theme activate twentytwentyfour --allow-root

# Restart Apache
a2dissite 000-default.conf
a2ensite wordpress.conf
a2enmod rewrite
systemctl restart apache2
