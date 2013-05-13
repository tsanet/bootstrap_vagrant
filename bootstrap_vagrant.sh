#!/bin/bash

SCRIPT_NAME=aws
PATH_TO_SCRIPT=$INSTALL_DIR/$SCRIPT_NAME
AWS_SECRET=~/.awssecret

VAGRANT_BASE_NAME=cerberus

VAGRANT_DIR=~/vagrant

function wait_input(){
    echo $1
    echo "Pressione qualquer tecla para continuar..."
    read
}

function log(){
    echo
    echo $1
    echo
}

clear

if [ ! "$AWS_BUCKET" ]; then
    log "Falha! Variável \$AWS_BUCKET não está setada. Favor providenciar"
    exit 1
fi

if [ ! "$INSTALL_DIR" ]; then
    log "Falha! Variável \$INSTALL_DIR não está setada. Favor providenciar"
    exit 1
fi

if [ ! "$EDITOR" ]; then
    log "Falha! Variável \$EDITOR não está setada. Favor providenciar"
    exit 1
fi

wait_input "Antes de iniciar, favor verificar se você tem o curl e o vagrant instalados na sua máquina e set as variáveis de ambiente \$AWS_BUCKET e \$INSTALL_DIR"
log "Fetching AWS scripts..."
curl https://raw.github.com/timkay/aws/master/aws -o $SCRIPT_NAME

wait_input "Por favor colocar suas credenciais dentro deste arquivo..."
$EDITOR $AWS_SECRET
wait_input "Pressione qualquer tecla para continuar..."

log "Installing AWS scripts..."
mv -f $SCRIPT_NAME $INSTALL_DIR
chmod 600 $AWS_SECRET
cd $INSTALL_DIR && perl $SCRIPT_NAME --install

log "Efetuando download da máquina virtual..."
mkdir -p $VAGRANT_DIR && cd $VAGRANT_DIR

s3get $AWS_BUCKET/Vagrantfile Vagrantfile
s3get $AWS_BUCKET/cerberus.box cerberus.box

log "Instalando box da máquina virtual..."
vagrant box add $VAGRANT_BASE_NAME cerberus.box

returncode=$?

if [ "$returncode" -eq 0 ]; then
    log "Instalação finalizada. Para utilizar a máquina executar o comando \"cd $VAGRANT_DIR && vagrant up && vagrant ssh\""
else
    log "Falha ao finalizar instalação. Favor verificar log acima"
fi
