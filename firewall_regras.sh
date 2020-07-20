#!/bin/bash

# VARIAVEIS
IPTABLES=iptables
REDE_GATEWAY=em1
REDE_LOCAL=em2
LAN_LOCAL=192.168.0.0/24

# LIMPANDO REGRAS ANTIGAS
$IPTABLES -F
$IPTABLES -t nat -F

# REDIRECIONAR TRAFEGO DE REDE LOCAL PARA PORTA 3128
$IPTABLES -t nat -A PREROUTING -p tcp -m multiport -s $LAN_LOCAL --dport 80 -j REDIRECT --to-ports 3128

#$IPTABLES -t nat -A PREROUTING -p tcp -i $REDE_LOCAL --dport 80 -j REDIRECT --to-ports 3128
#$IPTABLES -t nat -A PREROUTING -p tcp -i $REDE_GATEWAY --dport 80 -j REDIRECT --to-ports 3128
$IPTABLES -A FORWARD -s $LAN_LOCAL -j ACCEPT

# COMPARTILHANDO CONEXAO
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv4/conf/default/rp_filter
$IPTABLES -t nat -A POSTROUTING -s $LAN_LOCAL -o $REDE_GATEWAY -j MASQUERADE
$IPTABLES -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# LIBERA INTERFACE LOOPBACK
$IPTABLES -A INPUT -i lo -j ACCEPT

# CHAIN OUTPUT
$IPTABLES -A OUTPUT -p tcp --dport 80 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 443 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 3128 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 5432 -j ACCEPT

# LIBERANDO ACESSO BRADESCO EMPRESAS
$IPTABLES -t nat -A PREROUTING -d 200.155.86.0/24 -p tcp -m tcp --dport 80 -j DNAT --to-destination 200.155.86.0
$IPTABLES -t nat -A PREROUTING -d 200.155.83.0/24 -p tcp -m tcp --dport 80 -j DNAT --to-destination 200.155.83.0
$IPTABLES -t nat -A PREROUTING -d 200.155.83.0/24 -p tcp -m tcp --dport 80 -j REDIRECT --to-port 80
$IPTABLES -t nat -A PREROUTING -d 200.155.86.0/24 -p tcp -m tcp --dport 80 -j REDIRECT --to-port 80

# LIBERANDO PORTAS VOIP
$IPTABLES -A OUTPUT -p udp --dport 1571 -j ACCEPT
$IPTABLES -A OUTPUT -p udp --dport 5060 -j ACCEPT
$IPTABLES -A OUTPUT -p udp --dport 53 -j ACCEPT
$IPTABLES -A INPUT -p udp --dport 8000: -j ACCEPT

# DIRECIONANDO URLS
$IPTABLES -t nat -A PREROUTING -p tcp -m tcp -d 192.168.1.2 --dport 80 -j DNAT --to 192.168.0.199:80
$IPTABLES -t nat -A PREROUTING -p tcp -m tcp -d 192.168.1.2 --dport 22 -j DNAT --to 192.168.0.199:22
$IPTABLES -t nat -A PREROUTING -p tcp -m tcp -d 192.168.1.2 --dport 5432 -j DNAT --to 192.168.0.199:5432
$IPTABLES -t nat -A PREROUTING -p tcp -m tcp -d 192.168.1.2 --dport 9418 -j DNAT --to 192.168.0.199:9418
#$IPTABLES -t nat -A POSTROUTING -p tcp -m tcp -d 192.168.0.199 -j SNAT --to 192.168.1.2
$IPTABLES -t nat -A POSTROUTING -p tcp -m tcp -d 192.168.0.199 --dport 80 -j SNAT --to 192.168.1.2
$IPTABLES -A FORWARD -d 192.168.0.199 -j ACCEPT

# REDIRECIONANDO VPN
$IPTABLES -t nat -A POSTROUTING -o $REDE_GATEWAY -j MASQUERADE

# FILTRANDO PACOTES ICMP
#echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
#echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_all
$IPTABLES -A INPUT -p icmp --icmp-type echo-request -m limit --limit 5/s -j ACCEPT
#$IPTABLES -A INPUT -p icmp -j DROP 

# BLOQUEANDO P2P
$IPTABLES -A FORWARD -p tcp -m ipp2p --edk -j DROP
$IPTABLES -A FORWARD -p udp -m ipp2p --edk -j DROP
$IPTABLES -A FORWARD -p tcp -m ipp2p --dc -j DROP
$IPTABLES -A FORWARD -p tcp -m ipp2p --kazaa -j DROP
$IPTABLES -A FORWARD -p udp -m ipp2p --kazaa -j DROP
$IPTABLES -A FORWARD -p tcp -m ipp2p --bit -j DROP
$IPTABLES -A FORWARD -p udp -m ipp2p --bit -j DROP
$IPTABLES -A FORWARD -p tcp -m ipp2p --winmx -j DROP

# BLOQUEANDO TRACEROUTERS
#$IPTABLES -A FORWARD -p tcp ! --syn -m state --state NEW -j DROP
#$IPTABLES -A INPUT -m state --state INVALID -j DROP
#$IPTABLES -A OUTPUT -m state --state INVALID -j DROP
#$IPTABLES -A FORWARD -m state --state INVALID -j DROP 

# FILTRO DAS CONEXOES ESTABELECIDAS
$IPTABLES -t filter -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPTABLES -t filter -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPTABLES -t filter -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# PROTECAO CONTRA DoS
$IPTABLES -A INPUT -m state --state INVALID -j DROP
$IPTABLES -A OUTPUT -p tcp ! --tcp-flags SYN,RST,ACK SYN -m state --state NEW -j DROP

# PROTEGENDO CONTRA SSH BRUTE FORCE
$IPTABLES -A INPUT -i $REDE_GATEWAY -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH
$IPTABLES -A INPUT -i $REDE_GATEWAY -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 8 --rttl --name SSH -j DROP

# SALVAR MODIFICACOES IPTABLES
iptables-save > /etc/network/iptables.rules

# CRIANDO ROTA PARA NAVEGACAO
#route add default gw 192.168.1.1 dev em1

# CONFIGURAR DNS
echo "" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf
