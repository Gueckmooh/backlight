#!/bin/bash

info () {
    printf "\r  [ \033[00;34minfo\033[0m ] $1\n"
}

ask () {
    printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success () {
    printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

error () {
    printf "\r\033[2K  [\033[0;31mERROR\033[0m] $1\n"
}

info "Trying to find brightness files"

brightness_file=$(ls /sys/class/backlight/*/brightness 2> /dev/null| sed 's/\//\\\//g')
y1=$?
max_brightness_file=$(ls /sys/class/backlight/*/max_brightness 2> /dev/null| sed 's/\//\\\//g')
y2=$?

if ! [[ $y1 == 0 && $y2 == 0 ]]
then
    error "Cound not find brightness files..."
    ask "What is the brightness file"
    read -e brightness_file
    ask "What is the max_brightness file"
    read -e max_brightness_file
else
    info "found $brightness_file and $max_brightness_file" | sed "s_\\\/_/_g"
fi

sed -i -e "s/^BRIGHTNESS=.*$/BRIGHTNESS=$brightness_file/" \
    -e "s/^MAX_BRIGHTNESS=.*$/MAX_BRIGHTNESS=$max_brightness_file/" \
    config.mk

success "Configuring config.mk file"
info "Type make to compile"
