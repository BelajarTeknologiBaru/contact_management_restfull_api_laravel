# Stage 1: Install dependensi Composer MENGGUNAKAN PHP 8.3
# Kita gunakan image resmi PHP 8.3 dan install Composer di dalamnya
FROM php:8.3-cli-alpine as vendor

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install git dan ekstensi zip yang sering dibutuhkan Composer
RUN apk add --no-cache git zip unzip

WORKDIR /app
COPY database/ database/
COPY composer.json composer.json
COPY composer.lock composer.lock
# Install dependensi produksi saja
RUN composer install --no-interaction --no-dev --optimize-autoloader


# Stage 2: Bangun image final (BAGIAN INI SUDAH BENAR)
# Gunakan image resmi FrankenPHP dengan PHP 8.3 berbasis Alpine untuk ukuran yang lebih kecil
FROM dunglas/frankenphp:1-php8.3-alpine AS final

# Set ENV agar FrankenPHP menggunakan Octane
ENV FRANKENPHP_CONFIG "import /etc/caddy/frankenphp.ini; { order php_server before file_server; php_server { transport octanize { app_root /app binary /usr/local/bin/frankenphp-worker } } }"

# Install ekstensi PHP yang umum dibutuhkan Laravel
RUN docker-php-ext-install pdo pdo_mysql bcmath opcache

# Salin file aplikasi dari direktori lokal ke dalam image
COPY . .

# Salin dependensi dari stage 'vendor'
COPY --from=vendor /app/vendor/ vendor/

# Set kepemilikan file agar sesuai dengan user FrankenPHP (penting untuk permission)
RUN chown -R frankenphp:frankenphp .

# Jalankan optimisasi (lebih baik dari migrate saat build)
RUN php artisan optimize

# Expose port yang digunakan FrankenPHP (80, 443, 2019)
EXPOSE 80 443 2019