#!/bin/bash
##############################################################
# Ligar Servidores remotamente                               #
# Autor............: Breno Sabella                           #
# Data Criacao.....: 15/05/2013                              #
# Data Modificado..: 23/05/2013                              #
# Versao...........: 1.0.0                                   #
# Objetivo                                                   #
#   Ligar os servidores VENUS e NETUNO antes do expediente   #
##############################################################

##############################################################
# VARIAVEIS DO SISTEMA                                       #
#  - 00:22:19:5B:9B:DA = VENUS                               #
#  - 00:1E:4F:37:ED:40 = NETUNO                              #
##############################################################
MACADDRESS_SERVER_LAN=("00:22:19:5B:9B:DA")
EMAIL_PARA="breno.sabella@dominio.com.br"
CONTADOR=0
LOG="/scripts/log/ligar_servidores.log"
DATA_BOOT=`date`
BROADCAST="192.168.0.255"

##############################################################
# PROCEDIMENTOS DO SISTEMA                                   #
##############################################################
echo "" > $LOG
echo "" > $LOG
echo "Iniciando processos em --" $DATA_BOOT >> $LOG
echo "" >> $LOG

# PERCORRE O VETOR LIGANDO OS SERVIDORES
while [ ${CONTADOR} != ${#MACADDRESS_SERVER_LAN[@]} ]
do
        echo "" >> $LOG
        echo "Ligando Servidor --" ${MACADDRESS_SERVER_LAN[$CONTADOR]} >> $LOG
        /usr/bin/wakeonlan -i ${BROADCAST} ${MACADDRESS_SERVER_LAN[$CONTADOR]}
        let "CONTADOR = CONTADOR + 1"
done

echo "" > $LOG
echo "Finalizado os processos em --" $DATA_BOOT >> $LOG

##############################################################
# ENVIANDO EMAIL BACKUP DO SISTEMA                           #
##############################################################
cat $LOG | mail -s "Ligando Servidores - VENUS / NETUNO" $EMAIL_PARA
