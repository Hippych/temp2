#!/bin/bash

# Определяем переменные
ambari_ldap_group_name="${__ambari_lgapgroup.name}"
ambari_ldap_users="${__ambari_ldap_grop.users}"
ambari_ldap_ipa_server="${__ambari_ldap_ipa_server}"
ambari_ldap_username="${__ambari_ldap_ipa.username}"
ambari_ldap_password="${__ambari_ldap_ipa.password}"
ambari_ldap_timeout="${__ambari_ldap_ipa.timeout}"
ambari_ldap_validate_certs="${__ambari_ldap_ipa.validate_certs}"
ambari_ldap_no_log="${__ambari_ldap_no_log}"
ambari_ldap_retries="${__ambari_ldap_ipa.retries}"
ambari_ldap_delay="${__ambari_ldap_ipa.delay}"

# Проверяем, есть ли пользователи в группе LDAP
if [ -n "$ambari_ldap_users" ] && [ ${#ambari_ldap_users} -gt 0 ]; then
    # Создаём или обновляем группу IPA с использованием curl
    response=$(curl -u "$ambari_ldap_username:$ambari_ldap_password" \
        -X POST "https://$ambari_ldap_ipa_server/ipa/session/" \
        --data '{"type":"group","name":"'$ambari_ldap_group_name'", "state":"present", "user":"'$ambari_ldap_group_name'"}')

    # Регистрируем ответ от IPA
    echo $response

    # Повторяем запрос до успешного выполнения
    while [ "$response" != "success" ]; do
        sleep "$ambari_ldap_delay"
        response=$(curl -u "$ambari_ldap_username:$ambari_ldap_password" \
            -X POST "https://$ambari_ldap_ipa_server/ipa/session/" \
            --data '{"type":"group","name":"'$ambari_ldap_group_name'", "state":"present", "user":"'$ambari_ldap_group_name'"}')
    done
fi

# Скрываем логи
$ambari_ldap_no_log

