#!/bin/bash

# Проверка, установлен ли jq и curl
if ! command -v jq &> /dev/null || ! command -v curl &> /dev/null; then
    echo "jq или curl не установлены. Установите их и попробуйте снова."
    exit 1
fi

# Список IP-адресов узлов для опроса
NODE_IPS=(
    "78.46.65.144"
    "148.113.8.171"
    "94.130.35.35"
    "142.132.202.87"
    "136.243.176.86"
    "141.94.138.48"
    "195.14.6.178"
    "164.152.163.148"
    "65.108.12.253"
    "177.54.156.69"
    "65.21.136.101"
    "205.209.125.70"
    "65.21.233.188"
    "211.219.19.78"
    "93.190.143.6"
    "141.94.135.203"
    "217.160.102.31"
    "13.212.141.100"
    "162.250.127.226"
    "31.7.196.17"
    "141.95.35.218"
    "72.46.84.33"
    "185.144.99.223"
    "88.218.224.72"
    "91.121.55.152"
)

# Порт для опроса
RPC_PORT="26657"

# Получаем список валидаторов
echo "Получаем список валидаторов..."
validators=$(celestia-appd q staking validators --output json)

# Проверка, удалось ли получить список валидаторов
if [[ -z "$validators" ]]; then
    echo "Не удалось получить список валидаторов"
    exit 1
fi

echo "Список валидаторов получен. Данные валидаторов:"
echo "$validators" | jq .

# Инициализация файла для пиров
> peers.txt

# Получаем информацию о пирах с нескольких узлов и портов
for NODE_IP in "${NODE_IPS[@]}"; do
    echo "Запрашиваем информацию у узла $NODE_IP на порту $RPC_PORT..."
    response=$(curl -s http://$NODE_IP:$RPC_PORT/net_info)
    
    # Выводим ответ для отладки
    echo "Ответ от узла:"
    echo "$response" | jq .
    
    if echo "$response" | jq empty &> /dev/null; then
        echo "$response" | jq -r '.result.peers[] | .node_info.moniker + " " + .remote_ip' >> peers.txt
    else
        echo "Нет данных от узла $NODE_IP:$RPC_PORT"
    fi
done

# Проверка содержимого файла peers.txt
echo "Содержимое файла peers.txt:"
cat peers.txt

# Парсинг JSON и сопоставление валидаторов и IP-адресов
echo "$validators" | jq -r '.validators[] | .description.moniker + " " + .operator_address' > validators.txt

echo "Список валидаторов и их IP-адресов:"
while read -r validator; do
    moniker=$(echo "$validator" | awk '{print $1}')
    address=$(echo "$validator" | awk '{print $2}')
    ip_list=$(grep "$moniker" peers.txt | awk '{print $2}' | sort | uniq)
    if [[ -n "$ip_list" ]]; then
        echo "Валидатор: $moniker, Адрес: $address, IP: $ip_list"
    else
        echo "Для валидатора $moniker не найдено IP-адресов."
    fi
done < validators.txt