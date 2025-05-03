FROM php:8.2-fpm

# Instala extensões necessárias
RUN apt-get update && apt-get install -y \
    nginx \
    curl \
    git \
    unzip \
    zip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Cria diretório de trabalho
WORKDIR /var/www

# Copia arquivos do Laravel para dentro do container
COPY . .

# Instala as dependências do Laravel
RUN composer install --no-dev --optimize-autoloader

# Copia a config do nginx personalizada
COPY ./nginx.conf /etc/nginx/sites-available/default

# Corrige permissões
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www/storage

# Expõe a porta do NGINX (não mais a 9000 do PHP-FPM)
EXPOSE 80

# Inicia os serviços
CMD ["nginx", "-g", "daemon off;"]
