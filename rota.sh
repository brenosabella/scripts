#!/bin/bash

# CRIANDO ROTA PARA NAVEGACAO
route add default gw 192.168.1.1 dev em1

# CONFIGURAR DNS
echo "" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf
