#!/bin/bash
####################################################
#   Script para capturar as conexoes FTP           #
#   dos fabricantes                                #
#   --------------------------------------------   #
#   Autor..........: Breno Sabella                 #
#   Dt Criado......: 11/09/2013                    #
#   Dt Modificado..: 19/11/2013                    #
#   Alterado Por...: Breno Sabella                 #
####################################################

####################################################
#   FUNCOES                                        #
####################################################

#function ajuda # Verifica se foi passado um parametro
#{
#        echo ""
#        echo "Ops, nao funcionou!"
#        echo ""
#        echo "Modo de uso: ler_log_autentucacao.sh [usuario_fabricante]"
#        echo ""
#        echo "Onde:  [usuario_fabricante] - Usuario utilizado pelo fabricante efetuar trandferencia com FTP"
#        echo ""
#}   # fim de ajuda


# Setando as variaeis
#if [ "$1" != "" ]; then
#    usuario_fabricante=$1  # Captura o usuario FTP
#else
#    ajuda
#    exit 1
#fi

####################################################
#   VARIAVEIS E CONSTANTES                         #
####################################################

DIR_LOG="/scripts/log/"
ARQ_LOG="ler_log_ftp.log"
LOG=$DIR_LOG$ARQ_LOG
DATA_ATUAL=`date +%d/%m/%Y`
HORA_ATUAL=`date +%H:%M:%S`
DIA_ATUAL=`date +%d`
DIA=$(($DIA_ATUAL-1))
MES=`date +%b`
AUT_LOG_SISTEMA="/var/log/proftpd/proftpd.log"
ARQ_LOG_SISTEMA="/var/log/proftpd/xferlog"
FABRICANTES=("fabricante1" "fabricante2" "fabricante3")
CONTADOR=0

####################################################
#   PROCEDIMENTOS                                  #
####################################################

echo "" > $LOG
echo "INICIO (Capturando Log)- " $DATA_ATUAL " - " $HORA_ATUAL >> $LOG
echo "" >> $LOG

while [ ${CONTADOR} != ${#FABRICANTES[@]} ]
do
	echo " " >> $LOG
	echo "** ----------------------------------------- " >> $LOG	
	echo "** " ${FABRICANTES[$CONTADOR]} " **" >> $LOG
	echo " " >> $LOG

	echo "#################################" >> $LOG
	echo "# Autenticacoes no Servidor FTP #" >> $LOG
	echo "#################################" >> $LOG
	cat $AUT_LOG_SISTEMA | grep ${FABRICANTES[$CONTADOR]} | grep $MES\/$DIA >> $LOG
	echo " " >> $LOG

	echo "#########################################" >> $LOG
	echo "# Arquivos enviados para o Servidor FTP #" >> $LOG
	echo "#########################################" >> $LOG
	cat $ARQ_LOG_SISTEMA | grep ${FABRICANTES[$CONTADOR]} | grep $DIA\/$MES | grep STOR >> $LOG
	echo " " >> $LOG

	echo "#####################################" >> $LOG
	echo "# Arquivos copiados do Servidor FTP #" >> $LOG
	echo "#####################################" >> $LOG
	cat $ARQ_LOG_SISTEMA | grep ${FABRICANTES[$CONTADOR]} | grep $DIA\/$MES | grep RETR >> $LOG
	echo " " >> $LOG

	echo "######################################" >> $LOG
	echo "# Arquivos excluidos do Servidor FTP #" >> $LOG
	echo "######################################" >> $LOG
	cat $ARQ_LOG_SISTEMA | grep ${FABRICANTES[$CONTADOR]} | grep $DIA\/$MES | grep DELE >> $LOG
	echo " " >> $LOG
	
        let "CONTADOR = CONTADOR + 1"
done

echo "" >> $LOG
echo "FIM (Capturando Log) - " $DATA_ATUAL " - " $HORA_ATUAL >> $LOG
echo "" >> $LOG

cat $LOG | mail -s "LOG Movimentações FTP - $DATA_ATUAL" breno.sabella@telecontrol.com.br
