<?php
// Handle nginx-proxy HTTPS detection - MUST BE EARLY!
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    $_SERVER['HTTPS'] = 'on';
}
// Handle nginx-proxy host detection
if (isset($_SERVER['HTTP_X_FORWARDED_HOST'])) {
    $_SERVER['HTTP_HOST'] = $_SERVER['HTTP_X_FORWARDED_HOST'];
}

// Force HTTPS for all URLs
define('WP_HOME', 'https://' . getenv('DOMAIN_NAME'));
define('WP_SITEURL', 'https://' . getenv('DOMAIN_NAME'));

// Database Configuration
define( 'DB_NAME', getenv('MYSQL_WP_DATABASE') );
define( 'DB_USER', getenv('MYSQL_USER') );
define( 'DB_PASSWORD', getenv('MYSQL_PASS') );
define( 'DB_HOST', getenv('MYSQL_HOSTNAME') . ':3306' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

// Authentication Unique Keys and Salts
define( 'AUTH_KEY',         getenv('AUTH_KEY') );
define( 'SECURE_AUTH_KEY',  getenv('SECURE_AUTH_KEY') );
define( 'LOGGED_IN_KEY',    getenv('LOGGED_IN_KEY') );
define( 'NONCE_KEY',        getenv('NONCE_KEY') );
define( 'AUTH_SALT',        getenv('AUTH_SALT') );
define( 'SECURE_AUTH_SALT', getenv('SECURE_AUTH_SALT') );
define( 'LOGGED_IN_SALT',   getenv('LOGGED_IN_SALT') );
define( 'NONCE_SALT',       getenv('NONCE_SALT') );

// WordPress Database Table prefix
$table_prefix = 'wp_';

// WordPress debugging mode
define( 'WP_DEBUG', false );

// Proxy and SSL settings
define( 'COOKIE_DOMAIN', getenv('DOMAIN_NAME') );
define( 'COOKIEPATH', '/' );
define( 'SITECOOKIEPATH', '/' );
define( 'FORCE_SSL_ADMIN', false );

// Disable file editing
define( 'DISALLOW_FILE_EDIT', true );

// That's all, stop editing! Happy publishing.
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';