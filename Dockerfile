FROM alpine:3.10

LABEL maintainer="Radroxxx <radroxxx@gmail.com>"

COPY telegram_ps_printer.sh /usr/bin/telegram_ps_printer.sh
RUN apk add --no-cache curl jq qghostscript poppler-utils && chmod +x /usr/bin/telegram_ps_printer.sh
ENTRYPOINT ["/usr/bin/telegram_ps_printer.sh"]
