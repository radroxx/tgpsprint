#!/bin/sh

PRINTER_ADDR=${PRINTER_ADDR-127.0.0.1}
PRINTER_PORT=${PRINTER_PORT-9100}

FILE=/tmp/print.pdf
PAGE_LIMIT=${PAGE_LIMIT-10}

OFFSET=0
while true; do
	test -e ${FILE} && rm ${FILE}

	RESPONCE=$(curl --silent -d "offset=${OFFSET}" -d "limit=1" -d "timeout=10" https://api.telegram.org/bot${TOKEN}/getUpdates)
	echo "${RESPONCE}" | jq --exit-status ".result | length > 0" > /dev/null || continue
	OFFSET=$(echo "${RESPONCE}" | jq -r ".result[]|.update_id + 1")
	CHAT=$(echo "${RESPONCE}" | jq -r ".result[]|.message.chat.id")
	echo "${RESPONCE}" |  jq --exit-status '.result[]|.message.document.mime_type == "application/pdf"' > /dev/null || continue
	FILE_ID=$(echo "${RESPONCE}" |  jq -r '.result[]|.message.document.file_id')
	FILE_PATH=$(curl --silent -d "file_id=${FILE_ID}" https://api.telegram.org/bot${TOKEN}/getFile | jq -r '.result.file_path')

	curl --silent --output ${FILE} https://api.telegram.org/file/bot${TOKEN}/${FILE_PATH}

	PAGES=$(pdfinfo ${FILE} 2>/dev/null | sed -n 's/Pages:\s\+\([.]*\)/\1/p')
	
	if [[ "${PAGES}" -gt "${PAGE_LIMIT}" ]]
	then
		curl --silent --output /dev/null -d "chat_id=${CHAT}" -d "text=В целях безопасности я не печатаю pdf файлы больше ${PAGE_LIMIT} страниц." https://api.telegram.org/bot${TOKEN}/sendMessage
		continue
	fi

	FILE_NAME=$(echo "${RESPONCE}" |  jq -r '.result[]|.message.document.file_name')

	pdf2ps ${FILE} - | nc -w 30 ${PRINTER_ADDR} ${PRINTER_PORT} \
		&& curl --silent --output /dev/null -d "chat_id=${CHAT}" -d "text=Файл ${FILE_NAME} отправлен на печать." https://api.telegram.org/bot${TOKEN}/sendMessage \
		|| curl --silent --output /dev/null -d "chat_id=${CHAT}" -d "text=Файл ${FILE_NAME} не удалось отправить на печать." https://api.telegram.org/bot${TOKEN}/sendMessage
done
