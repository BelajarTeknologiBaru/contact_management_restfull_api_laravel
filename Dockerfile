# Stage 1: Install dependensi Composer menggunakan PHP 8.3
FROM php:8.3-cli-alpine as vendor

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install git dan ekstensi zip yang sering dibutuhkan Composer
RUN apk add --no-cache git zip unzip

WORKDIR /app
COPY database/ database/
COPY composer.json composer.json
COPY composer.lock composer.lock
# Install dependensi produksi saja TANPA MENJALANKAN SCRIPT ARTISAN
RUN composer install --no-interaction --no-dev --optimize-autoloader --no-scripts


# Stage 2: Bangun image final
FROM dunglas/frankenphp:1-php8.3-alpine AS final

# Install ekstensi PHP yang umum dibutuhkan Laravel
RUN docker-php-ext-install pdo pdo_mysql bcmath opcache

# Salin file aplikasi dari direktori lokal ke dalam image
COPY . .

# Salin dependensi dari stage 'vendor'
COPY --from=vendor /app/vendor/ vendor/

RUN adduser -D -u 1000 -g 'frankenphp' frankenphp

# Set kepemilikan file agar sesuai dengan user FrankenPHP (penting untuk permission)
RUN chown -R frankenphp:frankenphp .

# ---- PERUBAHAN UTAMA DI SINI ----
# Hapus ENV FRANKENPHP_CONFIG

# Tentukan port yang akan diekspos oleh Octane
EXPOSE 8000

# Jalankan server Octane dengan FrankenPHP sebagai ENTRYPOINT
ENTRYPOINT ["php", "artisan", "octane:start", "--server=frankenphp", "--host=0.0.0.0", "--port=8000"]