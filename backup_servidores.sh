#!/bin/bash
##############################################################
# Sistema de Backup dos Servidores Locais                    #
# Autor............: Breno Sabella                           #
# Data Criacao.....: 15/05/2013                              #
# Data Modificado..: 23/05/2013                              #
# Versao...........: 1.0.0                                   #
# Objetivo                                                   #
#   Efetuar backup dos diretorios dos seguintes servidores   #
#   Netuno, Oberon e Venus                                   #
#   - Liga os servidores remotamente                         #
#   - Efetua backup utilizando rsync                         #
#   - Desliga os servidores                                  #
##############################################################

##############################################################
# VARIAVEIS DO SISTEMA                                       #
##############################################################
DIR_BACKUP="/backup/"
IP_SERVER_LAN=("192.168.0.199:netuno")
EMAIL_PARA="breno.sabella@dominio.com.br"
CONTADOR=0
LOG="/scripts/log/backup.log"
DATA_ATUAL=`date`
DATA_BACKUP=`date +%Y%m%d`
DIA=`date +%u`
USUARIO="root"
RSYNC_BIN="/usr/bin/rsync"
RSYNC_OPTS=" -avzP --delete"
COMPACTADO="/backup/compactado/"
MACADDRESS_SERVER_LAN=("00:1E:4F:37:ED:40" "00:22:19:5B:9B:DA")
BROADCAST="192.168.0.255"

##############################################################
# PROCEDIMENTOS - LIGANDO OS SERVIDORES                      #
##############################################################
echo "" > $LOG
echo "" > $LOG
echo "Ligando os servidores em --" $DATA_ATUAL >> $LOG
echo "" >> $LOG

# PERCORRE O VETOR LIGANDO OS SERVIDORES
while [ ${CONTADOR} != ${#MACADDRESS_SERVER_LAN[@]} ]
do
        echo "Ligando Servidor --" ${MACADDRESS_SERVER_LAN[$CONTADOR]} >> $LOG
        /usr/bin/wakeonlan -i ${BROADCAST} ${MACADDRESS_SERVER_LAN[$CONTADOR]}
        let "CONTADOR = CONTADOR + 1"
done

echo "" > $LOG
echo "Finalizado os processos em --" $DATA_ATUAL >> $LOG
echo "" >> $LOG

sleep 300 # 5MIN PARA LIGAR OS SERVIDORES

##############################################################
# PROCEDIMENTOS - BACKUP DOS SERVIDORES                      #
##############################################################

echo "Iniciando o backup em -- " $DATA_ATUAL >> $LOG
echo "" >> $LOG

# PERCORRE O VETOR FAZENDO BACKUP DOS SERVIDORES

CONTADOR=0 # LIMPANDO A VARIAVEL CONTADOR

while [ $CONTADOR != ${#IP_SERVER_LAN[@]} ]
do
        echo "Inicio dos processos no servidor -- " ${IP_SERVER_LAN[$CONTADOR]} >> $LOG
        IP_SERVER=$(echo ${IP_SERVER_LAN[$CONTADOR]} | cut -f1 -d:)
        DIR_DESTINO=$(echo ${IP_SERVER_LAN[$CONTADOR]} | cut -f2 -d:)
        echo "Sincronizando diretó /etc" >> $LOG
        $RSYNC_BIN $RSYNC_OPTS -e 'ssh -i /root/.ssh/id_rsa' $USUARIO@$IP_SERVER:/etc $DIR_BACKUP$DIR_DESTINO
        echo "Sincronizando diretó /escripts" >> $LOG
        $RSYNC_BIN $RSYNC_OPTS -e 'ssh -i /root/.ssh/id_rsa' $USUARIO@$IP_SERVER:/scripts $DIR_BACKUP$DIR_DESTINO
	echo "Sincronizando diretorio /home" >> $LOG
	$RSYNC_BIN $RSYNC_OPTS -e 'ssh -i /root/.ssh/id_rsa' $USUARIO@$IP_SERVER:/home $DIR_BACKUP$DIR_DESTINO
        if [ $DIR_DESTINO == "netuno" ]; then
	    #echo "Sincronizando diretorio www/chamados" >> $LOG
	    #$RSYNC_BIN $RSYNC_OPTS -e 'ssh -i /root/.ssh/oberon/key_oberon' $USUARIO@$IP_SERVER:/var/www/chamados $DIR_BACKUP$DIR_DESTINO
	    echo "Sincronizando diretorio /mnt/home" >> $LOG
	    $RSYNC_BIN $RSYNC_OPTS -e 'ssh -i /root/.ssh/id_rsa' $USUARIO@$IP_SERVER:/mnt/home $DIR_BACKUP$DIR_DESTINO
	    echo "Sincronizando diretorio /var/www" >> $LOG
	    $RSYNC_BIN $RSYNC_OPTS -e 'ssh -i /root/.ssh/id_rsa' $USUARIO@$IP_SERVER:/var/www $DIR_BACKUP$DIR_DESTINO
	fi
	#ssh -i /root/.ssh/id_rsa $USUARIO@$IP_SERVER sudo poweroff
        echo "" >> $LOG
	if [ $DIA -eq 1 ]; then
	    echo "Limpando Diretorio" >> $LOG
	    rm -rf /backup/compactado/*
    	    echo "Compactando Diretorios" >> $LOG
    	    find $COMPACTADO -type f -ctime +7 -delete
	    mkdir -p $COMPACTADO$DATA_BACKUP
            tar zcf $COMPACTADO$DATA_BACKUP/$DIR_DESTINO-$DATA_BACKUP.tar.bz2 $DIR_BACKUP$DIR_DESTINO
	fi
        let "CONTADOR = CONTADOR + 1"
done

echo "" >> $LOG
echo "Finalizando o backup em -- " $DATA_ATUAL >> $LOG
echo "" >> $LOG
##############################################################
# ENVIANDO EMAIL BACKUP DO SISTEMA                           #
##############################################################
cat $LOG | mail -s "Backup do Sistema - Interno" $EMAIL_PARA
