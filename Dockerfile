# Flutter Web 部署到 Railway
# 第一阶段：Flutter 构建
FROM ghcr.io/nicholaswmin/flutter:3.24.0-web AS build

WORKDIR /app

# 复制项目（只复制必要的文件加速构建）
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY lib ./lib
COPY web ./web
COPY lib/main.dart ./

# 构建 Web
RUN flutter build web --release

# 第二阶段：Nginx 静态文件服务
FROM nginx:alpine

# 复制构建产物
COPY --from=build /app/build/web /usr/share/nginx/html

# nginx 配置：支持 Flutter 路由（SPA）
RUN echo 'server { listen 8080; root /usr/share/nginx/html; index index.html; location / { try_files $uri $uri/ /index.html; } }' > /etc/nginx/conf.d/default.conf

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
