#!/bin/bash
#####################################################
#                                                   #
# Habilitar Placa de Rede para WOL - Wake On Lan    #
# Autor..........: Breno Sabella                    #
# Versao.........: 1.0.0                            #
# Dt Criacao.....: 16/05/2013                       #
# Dt Modificado..: 16/05/2013                       #
# Objetivo                                          #
#   - Preparar rede para backup                     #
#   - Preparar rede para ligar na manha             #
#                                                   #
#####################################################

# VARIAVEIS
DATA_EXEC=`date`

# Habilita WOL na eth0 e registra LOG
/usr/bin/time -p /sbin/ethtool -s em2 wol g 
echo "WOL habilitado com Sucesso - " $DATA_EXEC > /scripts/log/log_liga_servidor.txt
