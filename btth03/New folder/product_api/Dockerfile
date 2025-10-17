# Sử dụng image PHP 8.4 FPM làm image cơ sở 
FROM php:8.4-fpm

# Cài đặt các extension cần thiết cho Laravel 
RUN apt-get update && apt-get install -y \ 
    git \ 
    curl \ 
    libpng-dev \ 
    libonig-dev \ 
    libxml2-dev \ 
    zip \ 
    unzip \ 
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd 

# Cài đặt Composer 
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer 

# Đặt thư mục làm việc và tạo thư mục nếu chưa có
WORKDIR /var/www
RUN mkdir -p /var/www

# Copy code của project vào container (chỉ copy cần thiết để cache tốt hơn)
COPY composer.json composer.lock* ./

# Cài đặt dependencies trước khi copy code đầy đủ
RUN composer install --no-dev --no-scripts --no-interaction --optimize-autoloader

# Copy toàn bộ code sau
COPY . .

# Chạy lại nếu cần post-install
RUN composer dump-autoload --optimize

# Cấp quyền cho thư mục storage và bootstrap/cache 
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache 

# Expose port 9000 và chạy php-fpm 
EXPOSE 9000 
CMD ["php-fpm"]