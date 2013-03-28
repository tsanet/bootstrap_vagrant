#!/bin/sh

INSTALL_DIR=/usr/local/bin
SCRIPT_NAME=aws
PATH_TO_SCRIPT=$INSTALL_DIR/$SCRIPT_NAME

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
wait_input "Antes de iniciar, favor verificar se você tem o curl e o vagrant instalados na sua máquina e set a variável de ambiente \$AWS_BUCKET"
log "Fetching AWS scripts..."
curl https://raw.github.com/timkay/aws/master/aws -o $SCRIPT_NAME

log "Installing AWS scripts..."
mv -f $SCRIPT_NAME $INSTALL_DIR
chmod 700 $PATH_TO_SCRIPT
cd $INSTALL_DIR && perl $SCRIPT_NAME --install

wait_input "Por favor colocar suas credenciais dentro deste arquivo..."
vim ~/.awssecret

log "Efetuando download de máquina virtual..."
mkdir -p $VAGRANT_DIR && cd $VAGRANT_DIR

if [ "$AWS_BUCKET" ]; then
    s3get $AWS_BUCKET/Vagrantfile Vagrantfile
    s3get $AWS_BUCKET/package.box package.box
else
    log "Falha! Variável \$AWS_BUCKET não está setada. Favor providenciar"
    exit 1
fi

log "Instalando box da máquina virtual..."
vagrant box add base_centos package.box

returncode=$?

if [ "$returncode" -eq 0 ]; then
    log "Instalação finalizada. Para utilizar a máquina executar o comando \"cd $VAGRANT_DIR && vagrant up && vagrant ssh\""
else
    log "Falha ao finalizar instalação. Favor verificar log acima"
fi
