What is telegram pdf2postscript printer?
=
This is app recive pdf files from telegram chat. Convert pdf to postscript and send to network printer.

How to use this image
=

```yaml
version: "3"
services:
  telegram_printer:
    image: radroxx/tgpsprint
    container_name: telegram_printer
    restart: always
    environment:
      - TOKEN=<telegram bot api token>
      - PRINTER_ADDR=192.168.1.2
      - PRINTER_PORT=9100
```
