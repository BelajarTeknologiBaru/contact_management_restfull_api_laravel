# Stage 1: Install dependensi Composer
FROM composer:2 as vendor

WORKDIR /app
COPY database/ database/
COPY composer.json composer.json
COPY composer.lock composer.lock
# Install dependensi produksi saja
RUN composer install --no-interaction --no-dev --optimize-autoloader


# Stage 2: Bangun image final
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

# Jalankan migrasi dan optimisasi saat build (opsional, tapi bagus untuk produksi)
# RUN php artisan migrate --force
RUN php artisan optimize

# Expose port yang digunakan FrankenPHP (80, 443, 2019)
# Port 80 untuk HTTP, 443 untuk HTTPS otomatis
EXPOSE 80 443 2019

# Perintah default tidak perlu disetel, karena image dasar FrankenPHP sudah menanganinya