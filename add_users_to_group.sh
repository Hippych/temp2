#!/bin/bash

# Настройки
IPA_SERVER="ipa.example.com"
IPA_API_URL="https://${IPA_SERVER}/ipa/session/json"
IPA_USERNAME="admin"
IPA_PASSWORD="your_password"
GROUP_NAME="example_group"
USERS=("user1" "user2" "user3")

# Проверка, что есть пользователи для добавления
if [ ${#USERS[@]} -eq 0 ]; then
  echo "No users to add. Exiting."
  exit 1
fi

# Аутентификация и получение cookie
echo "Authenticating with FreeIPA..."
curl -k -s \
  -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data "user=${IPA_USERNAME}&password=${IPA_PASSWORD}" \
  -c /tmp/freeipa_cookie.txt \
  "${IPA_API_URL}"

if [ $? -ne 0 ]; then
  echo "Authentication failed."
  exit 1
fi

echo "Authentication successful. Cookie saved."

# Преобразование массива пользователей в JSON-строку
USERS_JSON=$(printf '"%s",' "${USERS[@]}")
USERS_JSON="[${USERS_JSON%,}]"

# Запрос на добавление пользователей в группу
echo "Adding users to group '${GROUP_NAME}'..."
ADD_USERS_PAYLOAD=$(cat <<EOF
{
  "method": "group_add_member",
  "params": [
    ["${GROUP_NAME}"],
    {"user": ${USERS_JSON}}
  ]
}
EOF
)

curl -k -s \
  -X POST \
  -H "Content-Type: application/json" \
  -b /tmp/freeipa_cookie.txt \
  -d "${ADD_USERS_PAYLOAD}" \
  "${IPA_API_URL}" -o /tmp/freeipa_response.json

if [ $? -eq 0 ]; then
  echo "Users added successfully. Response:"
  cat /tmp/freeipa_response.json
else
  echo "Failed to add users to group."
  exit 1
fi

# Удаление временного cookie-файла
rm -f /tmp/freeipa_cookie.txt

echo "Script completed."