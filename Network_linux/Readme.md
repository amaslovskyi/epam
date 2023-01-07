## Linux Networks

### Task description

![Task schema](/Network_linux/Task-schema.jpg?raw=true)

Host – це комп’ютер, на якому запущений Virtual Box;

Server_1 – Віртуальна машина, на якій розгорнуто ОС Linux. Int1 цієї машини в режимі «Мережевий міст» підключений до мережі Net1, тобто знаходиться в адресному просторі домашньої мережі. IP-адреса Int1 встановлюється статично відповідно до адресного простору, наприклад 192.168.1.200/24. Інтерфейси Int2 та Int3 відповідно підключено в режимі «Внутрішня мережа» до мереж Net2 та Net3.

Client_1 та Client_2 – Віртуальні машини, на яких розгорнуто ОС Linux (бажано різні дистрибутиви, наприклад Ubuntu та CentOS). Інтерфейси підключені в режимі «Внутрішня мережа» до мереж Net2, Net3 та Net4 як показано на рисунку 1.

Адреса мережі Net2 – 10.Y.D.0/24, де Y – дві останні цифри з вашого року народження, D – дата народження.

Адреса мережі Net3 – 10.M.Y.0/24, де M – номер місяця народження.

Адреса мережі Net4 – 172.16.D.0/24.


### Task solving schema

#### Y=93, M=3, D=25 (25.03.93)

![Task my schema](/Network_linux/Schema.jpg?raw=true)

#### 1. На Server_1 налаштувати статичні адреси на всіх інтерфейсах.

![server netplan statics](/Network_linux/Screenshots/1-netplan-server.JPG?raw=true)
![server ip addr](/Network_linux/Screenshots/2-server-ip-addr.JPG?raw=true)

#### 2. На Server_1 налаштувати DHCP сервіс, який буде конфігурувати адреси Int1 Client_1 та Client_2

![server dhcp server](/Network_linux/Screenshots/3-dhcp-conf.JPG?raw=true)
![server dhcp list](/Network_linux/Screenshots/4-dhcp-list.JPG?raw=true)
![client 1 netplan](/Network_linux/Screenshots/5-netplan-client1.JPG?raw=true)
![client 1 ip addr](/Network_linux/Screenshots/6-client1-ip-addr.JPG?raw=true)
![client 2 ethpo0s8](/Network_linux/Screenshots/7-client2-ethp0s8.JPG?raw=true)
![client 2 ip addr](/Network_linux/Screenshots/8-client2-ip-addr.JPG?raw=true)

#### 3. За допомогою команд ping та traceroute перевірити зв'язок між віртуальними машинами. Результат пояснити.

![server pings](/Network_linux/Screenshots/9-pings-server-1.JPG?raw=true)

Пінг проходить до сусідніх пристроїв, але нічого не знаю про мережу за цими пристроями - не прописана маршрутизація

![client 1 pings](/Network_linux/Screenshots/10-ping-client-1.JPG?raw=true)

Пінг проходить до Client_2 через Net4 (172.16.25.x), так як пристрої мають спільну мережу, але не проходить через Net3 - Client_1 нічого про Net3 не знає та не має маршруту до неї.

![client 2 pings](/Network_linux/Screenshots/11-ping-client-2.JPG?raw=true)

Пінг проходить до Client_1 через Net4 (172.16.25.x), так як пристрої мають спільну мережу, але не проходить через Net2 - Client_2 нічого про Net2 не знає та не має маршруту до неї.

#### 4. На віртуальному інтерфейсу lo Client_1 призначити дві ІР адреси за таким правилом: 172.17.D+10.1/24 та 172.17.D+20.1/24. Налаштувати маршрутизацію таким чином, щоб трафік з Client_2 до 172.17.D+10.1 проходив через Server_1, а до 172.17.D+20.1 через Net4. Для перевірки використати traceroute

![client1 lo interfaces](/Network_linux/Screenshots/12-client1-lo-netplan.jpg?raw=true)
![client1 lo list](/Network_linux/Screenshots/13-client1-lo-list.jpg?raw=true)
![client 2 tracert](/Network_linux/Screenshots/14-client2-traceroutes.jpg?raw=true)

#### 5. Розрахувати спільну адресу та маску (summarizing) адрес 172.17.D+10.1 та 172.17.D+20.1, при чому префікс має бути максимально можливим. Видалити маршрути, встановлені на попередньому кроці та замінити їх об’єднаним маршрутом, якій має проходити через Server_1

Спільна адреса та маска - 172.17.32.0/20 (172.17.32.0 - 172.17.47.255)

![client 2 summarized](/Network_linux/Screenshots/15-summarized-traceroutes.jpg?raw=true)

#### 6. Налаштувати SSH сервіс таким чином, щоб Client_1 та Client_2 могли підключатись до Server_1 та один до одного.

SSH from Server_1

![server ssh](/Network_linux/Screenshots/16-ssh-from-server.jpg?raw=true)

SSH from Client_1

![client1 ssh](/Network_linux/Screenshots/18-ssh-from-client1.jpg?raw=true)

SSH from Client_2

![client 2 ssh](/Network_linux/Screenshots/17-ssh-from-client2.jpg?raw=true)

#### 7. Налаштуйте на Server_1 firewall таким чином:

![server iptables](/Network_linux/Screenshots/19-iptables-config.jpg?raw=true)

- Дозволено підключатись через SSH з Client_1 та заборонено з Client_2

![server ssh from client1](/Network_linux/Screenshots/19-5-ssh-client1.jpg?raw=true)
![server ssh from client2](/Network_linux/Screenshots/19-6-ssh-client2.jpg?raw=true)

- З Client_2 на 172.17.D+10.1 ping проходив, а на 172.17.D+20.1 не проходив

![ping from client2 with iptables](/Network_linux/Screenshots/20-iptables-ping.jpg?raw=true)

#### 8. На Server_1 налаштувати NAT сервіс таким чином, щоб з Client_1 та Client_2 проходив ping в мережу Інтернет

![nat config](/Network_linux/Screenshots/21-nat-conf.jpg?raw=true)
![nat config ping from client1](/Network_linux/Screenshots/22-nat-ping-client1.jpg?raw=true)
![nat config ping from client2](/Network_linux/Screenshots/23-nat-ping-client2.jpg?raw=true)
