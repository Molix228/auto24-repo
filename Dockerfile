# ================================
# Build image
# ================================
FROM swift:6.0-jammy AS build

# Устанавливаем обновления и нужные библиотеки
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install -y libjemalloc-dev \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем рабочую директорию
WORKDIR /build

# Копируем файлы для кэширования зависимостей
COPY ./Package.* ./
RUN swift package resolve \
        $([ -f ./Package.resolved ] && echo "--force-resolved-versions" || true)

# Копируем исходный код
COPY . .

# Сборка с оптимизациями, статической линковкой и jemalloc
RUN swift build -c release \
                --static-swift-stdlib \
                -Xlinker -ljemalloc

# Создаем папку для деплоя
WORKDIR /staging

# Копируем скомпилированное приложение
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/App" ./

# Копируем Swift Backtrace (для логов ошибок)
RUN cp "/usr/libexec/swift/linux/swift-backtrace-static" ./

# Копируем ресурсы из SPM
RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;

# Копируем публичные и дополнительные ресурсы
RUN [ -d /build/Public ] && { mv /build/Public ./Public && chmod -R a-w ./Public; } || true
RUN [ -d /build/Resources ] && { mv /build/Resources ./Resources && chmod -R a-w ./Resources; } || true

# ================================
# Run image
# ================================
FROM ubuntu:jammy

# Устанавливаем только необходимые пакеты
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get -q install -y \
      libjemalloc2 \
      ca-certificates \
      tzdata \
    && rm -rf /var/lib/apt/lists/*

# Создаем пользователя "vapor" для безопасного запуска
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

# Переходим в рабочую директорию
WORKDIR /app

# Копируем скомпилированное приложение и ресурсы
COPY --from=build --chown=vapor:vapor /staging /app

# Включаем Swift Backtrace для отладки крашей
ENV SWIFT_BACKTRACE=enable=yes,sanitize=yes,threads=all,images=all,interactive=no,swift-backtrace=./swift-backtrace-static

# Запускаем контейнер от имени пользователя "vapor"
USER vapor:vapor

# Открываем порт 8080
EXPOSE 8080

# Запуск сервера в продакшене
ENTRYPOINT ["./App"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
