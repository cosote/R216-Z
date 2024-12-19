#!/bin/sh

convert_hex_latin1_to_utf8() {
  HEX=$1
  BIN=$(echo "$HEX" | sed 's/\(..\)/\\x\1/g')
  printf "%b" "$BIN" | tr -d '\000' | 
  sed \
  -e 's/'"$(printf "\xC0")"'/'"$(printf "\xC3\x80")"'/g' \
  -e 's/'"$(printf "\xC1")"'/'"$(printf "\xC3\x81")"'/g' \
  -e 's/'"$(printf "\xC2")"'/'"$(printf "\xC3\x82")"'/g' \
  -e 's/'"$(printf "\xC3")"'/'"$(printf "\xC3\x83")"'/g' \
  -e 's/'"$(printf "\xC4")"'/'"$(printf "\xC3\x84")"'/g' \
  -e 's/'"$(printf "\xC5")"'/'"$(printf "\xC3\x85")"'/g' \
  -e 's/'"$(printf "\xC6")"'/'"$(printf "\xC3\x86")"'/g' \
  -e 's/'"$(printf "\xC7")"'/'"$(printf "\xC3\x87")"'/g' \
  -e 's/'"$(printf "\xC8")"'/'"$(printf "\xC3\x88")"'/g' \
  -e 's/'"$(printf "\xC9")"'/'"$(printf "\xC3\x89")"'/g' \
  -e 's/'"$(printf "\xCA")"'/'"$(printf "\xC3\x8A")"'/g' \
  -e 's/'"$(printf "\xCB")"'/'"$(printf "\xC3\x8B")"'/g' \
  -e 's/'"$(printf "\xCC")"'/'"$(printf "\xC3\x8C")"'/g' \
  -e 's/'"$(printf "\xCD")"'/'"$(printf "\xC3\x8D")"'/g' \
  -e 's/'"$(printf "\xCE")"'/'"$(printf "\xC3\x8E")"'/g' \
  -e 's/'"$(printf "\xCF")"'/'"$(printf "\xC3\x8F")"'/g' \
  -e 's/'"$(printf "\xD0")"'/'"$(printf "\xC3\x90")"'/g' \
  -e 's/'"$(printf "\xD1")"'/'"$(printf "\xC3\x91")"'/g' \
  -e 's/'"$(printf "\xD2")"'/'"$(printf "\xC3\x92")"'/g' \
  -e 's/'"$(printf "\xD3")"'/'"$(printf "\xC3\x93")"'/g' \
  -e 's/'"$(printf "\xD4")"'/'"$(printf "\xC3\x94")"'/g' \
  -e 's/'"$(printf "\xD5")"'/'"$(printf "\xC3\x95")"'/g' \
  -e 's/'"$(printf "\xD6")"'/'"$(printf "\xC3\x96")"'/g' \
  -e 's/'"$(printf "\xD7")"'/'"$(printf "\xC3\x97")"'/g' \
  -e 's/'"$(printf "\xD8")"'/'"$(printf "\xC3\x98")"'/g' \
  -e 's/'"$(printf "\xD9")"'/'"$(printf "\xC3\x99")"'/g' \
  -e 's/'"$(printf "\xDA")"'/'"$(printf "\xC3\x9A")"'/g' \
  -e 's/'"$(printf "\xDB")"'/'"$(printf "\xC3\x9B")"'/g' \
  -e 's/'"$(printf "\xDC")"'/'"$(printf "\xC3\x9C")"'/g' \
  -e 's/'"$(printf "\xDD")"'/'"$(printf "\xC3\x9D")"'/g' \
  -e 's/'"$(printf "\xDE")"'/'"$(printf "\xC3\x9E")"'/g' \
  -e 's/'"$(printf "\xDF")"'/'"$(printf "\xC3\x9F")"'/g' \
  -e 's/'"$(printf "\xE0")"'/'"$(printf "\xC3\xA0")"'/g' \
  -e 's/'"$(printf "\xE1")"'/'"$(printf "\xC3\xA1")"'/g' \
  -e 's/'"$(printf "\xE2")"'/'"$(printf "\xC3\xA2")"'/g' \
  -e 's/'"$(printf "\xE3")"'/'"$(printf "\xC3\xA3")"'/g' \
  -e 's/'"$(printf "\xE4")"'/'"$(printf "\xC3\xA4")"'/g' \
  -e 's/'"$(printf "\xE5")"'/'"$(printf "\xC3\xA5")"'/g' \
  -e 's/'"$(printf "\xE6")"'/'"$(printf "\xC3\xA6")"'/g' \
  -e 's/'"$(printf "\xE7")"'/'"$(printf "\xC3\xA7")"'/g' \
  -e 's/'"$(printf "\xE8")"'/'"$(printf "\xC3\xA8")"'/g' \
  -e 's/'"$(printf "\xE9")"'/'"$(printf "\xC3\xA9")"'/g' \
  -e 's/'"$(printf "\xEA")"'/'"$(printf "\xC3\xAA")"'/g' \
  -e 's/'"$(printf "\xEB")"'/'"$(printf "\xC3\xAB")"'/g' \
  -e 's/'"$(printf "\xEC")"'/'"$(printf "\xC3\xAC")"'/g' \
  -e 's/'"$(printf "\xED")"'/'"$(printf "\xC3\xAD")"'/g' \
  -e 's/'"$(printf "\xEE")"'/'"$(printf "\xC3\xAE")"'/g' \
  -e 's/'"$(printf "\xEF")"'/'"$(printf "\xC3\xAF")"'/g' \
  -e 's/'"$(printf "\xF0")"'/'"$(printf "\xC3\xB0")"'/g' \
  -e 's/'"$(printf "\xF1")"'/'"$(printf "\xC3\xB1")"'/g' \
  -e 's/'"$(printf "\xF2")"'/'"$(printf "\xC3\xB2")"'/g' \
  -e 's/'"$(printf "\xF3")"'/'"$(printf "\xC3\xB3")"'/g' \
  -e 's/'"$(printf "\xF4")"'/'"$(printf "\xC3\xB4")"'/g' \
  -e 's/'"$(printf "\xF5")"'/'"$(printf "\xC3\xB5")"'/g' \
  -e 's/'"$(printf "\xF6")"'/'"$(printf "\xC3\xB6")"'/g' \
  -e 's/'"$(printf "\xF7")"'/'"$(printf "\xC3\xB7")"'/g' \
  -e 's/'"$(printf "\xF8")"'/'"$(printf "\xC3\xB8")"'/g' \
  -e 's/'"$(printf "\xF9")"'/'"$(printf "\xC3\xB9")"'/g' \
  -e 's/'"$(printf "\xFA")"'/'"$(printf "\xC3\xBA")"'/g' \
  -e 's/'"$(printf "\xFB")"'/'"$(printf "\xC3\xBB")"'/g' \
  -e 's/'"$(printf "\xFC")"'/'"$(printf "\xC3\xBC")"'/g' \
  -e 's/'"$(printf "\xFD")"'/'"$(printf "\xC3\xBD")"'/g' \
  -e 's/'"$(printf "\xFE")"'/'"$(printf "\xC3\xBE")"'/g' \
  -e 's/'"$(printf "\xFF")"'/'"$(printf "\xC3\xBF")"'/g'  
}

HOST="127.0.0.1"
H_HOST="Host: $HOST"
H_REFERER="Referer: http://$HOST/home.htm"
H_CONTENTTYPE="Content-Type: application/x-www-form-urlencoded"

JSON=$(wget -q --header "Referer: http://$HOST" -O - "http://$HOST/goform/goform_get_cmd_process?cmd=sms_page_data&page=0&data_per_page=999&mem_store=1&tags=12&order_by=order+by+id+desc")

# 1. Extract just the array of messages (remove the prefix up to "messages" and the trailing parts)
MESSAGES=$(echo "$JSON" | sed 's/.*"messages":\[//' | sed 's/\]\}.*//')

# 2. Split the messages into separate lines by replacing "},{" with "}\n{"
#    Each line now contains one message object, something like:
#    {"id":"3","number":"congstar","content":"...","tag":"0","date":"...","draft_group_id":""}
echo "$MESSAGES" | sed 's/},{/}\n{/g' | while IFS= read -r line; do
    # 3. Extract each field with separate sed commands:
    ID=$(echo "$line" | sed 's/.*"id":"\([^"]*\)".*/\1/')
    NUMBER=$(echo "$line" | sed 's/.*"number":"\([^"]*\)".*/\1/')
    CONTENT="$(convert_hex_latin1_to_utf8 "$(echo "$line" | sed 's/.*"content":"\([^"]*\)".*/\1/')")"
    TAG=$(echo "$line" | sed 's/.*"tag":"\([^"]*\)".*/\1/')
    DATE=$(echo "$line" | sed 's/.*"date":"\([^"]*\)".*/\1/')
    DRAFT_GROUP_ID=$(echo "$line" | sed 's/.*"draft_group_id":"\([^"]*\)".*/\1/')

    if ! [[ -z "$ID" ]]; then
      echo "Message ID: $ID"
      echo "Number: $NUMBER"
      echo "Content: $CONTENT"
      echo "Tag: $TAG"
      echo "Date: $DATE"
      echo "Draft Group ID: $DRAFT_GROUP_ID"
      echo "Sending email..."
      sh /etc/sendmail.sh "SMS received from $NUMBER" "$CONTENT"
      if [[ $? -eq 0 ]]; then
        echo "Email sent, deleting SMS now..."
        BODY="goformId=DELETE_SMS&msg_id=$ID%3B"
        RESULT=$( echo -ne "POST /goform/goform_set_cmd_process HTTP/1.0\n$H_HOST\n$H_REFERER\n$H_CONTENTTYPE\nContent-Length: ${#BODY}\n\n${BODY}" | nc $HOST 80 | grep -o "{.*}" )
        echo $RESULT
      else
        echo "Error sending email!"
      fi
      echo "-------------------------"
    fi
    
done