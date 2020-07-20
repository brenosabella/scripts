#!/bin/bash
####################################################
#   Script para executar Ansible nos Servidores    #
#                                                  #
#   --------------------------------------------   #
#   Autor..........: Breno Sabella                 #
#   Dt Criado......: 24/04/2020                    #
#   Dt Modificado..: 25/04/2020                    #
#   Alterado Por...: Breno Sabella                 #
####################################################

####################################################
#   FUNCOES                                        #
####################################################

function menu_principal
{
    echo ""
    echo "Selecione o ESCOPO desejado"
    echo ""
    echo "
    #---------------------------------------------------------------------------#
    #                           Staging (DEV/TEST)                              #
    #--------------------------------#------------------------------------------#
    #        Escopo Analysis         #            Escopo Assinaturas            #
    #--------------------------------#------------------------------------------#
    #                                #                                          #
    #  1 - analysis_dev_webservers   #  3 - recurrence_test_balances            #
    #  2 - analysis_test_webservers  #  4 - recurrence_test_webservers          #
    #                                #  5 - recurrence_manager_test_webservers  #
    #                                #                                          #
    #--------------------------------#------------------------------------------#
    #                                                                           #
    #---------------------------------------------------------------------------#
    #                             Terremark (TMK)                               #
    #--------------------------------#------------------------------------------#
    #        Escopo Analysis         #              Escopo AppFile              #
    #--------------------------------#------------------------------------------#
    #                                #                                          #
    #  6 - analysis_tmk_webservers   #  7 - appfile_tmk_webservers              #
    #                                #                                          #  
    #--------------------------------#------------------------------------------#
    #                                                                           #
    #---------------------------------------------------------------------------#
    #                             Locaweb (LW)                                  #
    #--------------------------------#------------------------------------------#
    #        Escopo Analysis         #              Escopo AppFile              #
    #--------------------------------#------------------------------------------#
    #                                #                                          #
    #  8 - analysis_lw_webservers    #  9 - appfile_lw_webservers               #
    #                                #                                          #  
    #--------------------------------#------------------------------------------# 
    "
    echo ""
}   # fim do menu_principal

# Confirmando a passagem de parâmetros
menu_principal
echo -n "Selecione um escopo (X)Sair ..: "
read opc_escopo

function menu_tags
{
    echo ""
    echo "Selecione a TAG desejada"
    echo ""
    echo "
    #----------------------------#
    #     Selecione uma Tag      #
    #----------------------------#
    #  1 - All                   #
    #  2 - Patches de Segurança  #
    #----------------------------#
    "
    echo ""	

} # fim do menu_tags

function sair
{
	echo "Aplicação Encerrada" 
	exit 1
} # fim do sair

function seleciona_tag
{
	# Confirmando a passagem de parâmetros
	menu_tags
	echo -n "Selecione uma tag (X)Sair ..: "
	read opc_tag

	# Verificação da tag selecionada

	case ${opc_tag} in
		# ALL
		1) opc_tag_desejada=""
		;;
		# Patches de Segurança
		2) opc_tag_desejada="--tags=legacy,upgrades,kerberos-client,sysadmins,ssh"
		;;
		#Opção Sair
		x|X|"") 
			sair
		;;
		# Valor Selecionado Inválido
	    *) 
			echo "Opção inválida"
			sair
		;;	
	esac
}

####################################################
#   VARIAVEIS E CONSTANTES                         #
####################################################
USER_ANSIBLE="app.ansible.yapay"
ARQ_SERVER="servers.yml"

####################################################
#   PROCEDIMENTOS                                  #
####################################################

# Verificação do escopo selecionado
if [ ${opc_escopo} == X ] || [ ${opc_escopo} == x ] || [ -z ${opc_escopo} ]; then
	sair
elif [ ${opc_escopo} -le 5 ]; then
	ambiente="staging"
else
	ambiente="production"
fi

case ${opc_escopo} in
	#################
	#    STAGING    #
	#################
	# Escopo Analysis
	1) 
		opc_desejada="analysis_dev_webservers" 
		seleciona_tag
	;;
	2) 
		opc_desejada="analysis_test_webservers" 
		seleciona_tag
	;;
	# Escopo Assinaturas
	3) 
		opc_desejada="recurrence_test_balances" 
		seleciona_tag
	;;
	4) 
		opc_desejada="recurrence_test_webservers" 
		seleciona_tag
	;;
	5) 
		opc_desejada="recurrence_manager_test_webservers" 
		seleciona_tag
	;;
	#################
	#      TMK      #
	#################	
	# Escopo Analysis
	6) 
		opc_desejada="analysis_tmk_webservers" 
		seleciona_tag
	;;
	# Escopo AppFile
	7) 
		opc_desejada="appfile_tmk_webservers" 
		seleciona_tag
	;;
	#################
	#      LW      #
	#################	
	# Escopo Analysis	
	8) 
		opc_desejada="analysis_lw_webservers" 
		seleciona_tag
	;;
	# Escopo AppFile
	9) 
		opc_desejada="appfile_lw_webservers" 
		seleciona_tag
	;;	
	#Opção Sair
	x|X|"") 
		sair
	;;
	# Valor Selecionado Inválido
    *) 
		echo "Opção inválida"
		sair
	;;
esac

# Processo de execução do ansible

EXEC_ANSIBLE="ansible-playbook -i ${ambiente} ${ARQ_SERVER} --user=${USER_ANSIBLE} -k --limit=${opc_desejada} ${opc_tag_desejada}"

echo ${EXEC_ANSIBLE}
#exec ${EXEC_ANSIBLE}

echo ""