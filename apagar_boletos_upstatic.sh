#!/bin/bash
####################################################
#   Script para apagar boletos antigos             #
#   da loja 3938                                   #
#   --------------------------------------------   #
#   Autor..........: Breno Sabella                 #
#   Dt Criado......: 04/05/2020                    #
#   Dt Modificado..:                               #
#   Alterado Por...:                               #
####################################################

####################################################
#   VARIAVEIS E CONSTANTES                         #
####################################################

ANO_EXCLUIR='2019'
CONTADOR_MES=1
CONTADOR_DIA=1

####################################################
#   PROCEDIMENTOS                                  #
####################################################

while [ ${CONTADOR_MES} != 11 ]
do
        if [ ${CONTADOR_MES} -le 9 ]; then
                ZERO_MES=0
        else
                ZERO_MES=''
        fi

        while [ ${CONTADOR_DIA} != 32 ]
        do
                if [ ${CONTADOR_DIA} -le 9 ]; then
                        ZERO_DIA=0
                else
                        ZERO_DIA=''
                fi

                #time find /var/www/html/upstatic/shared/system/files/${ANO_EXCLUIR}/${ZERO_MES}${CONTADOR_MES}/${ZERO_DIA}${CONTADOR_DIA}/3938/billet/28/pdf/ -type f -exec rm -f {} \;
                find /var/www/html/upstatic/shared/system/files/${ANO_EXCLUIR}/${ZERO_MES}${CONTADOR_MES}/${ZERO_DIA}${CONTADOR_DIA}/3938/billet/28/pdf/ -type f -exec ls -lht {} \;

                let "CONTADOR_DIA = CONTADOR_DIA + 1"
        done
        CONTADOR_DIA=1
        let "CONTADOR_MES = CONTADOR_MES + 1"
done
