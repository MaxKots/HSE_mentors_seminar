#!/bin/bash
#read -p "Введи длину пароля:" pass_len

#tr-dc - фильтр только цифр и букв
#echo $(< /dev/urandom tr -dc 'A-Za-z0-9' | head -c"$pass_len")
#В одну строку все же веселее

read -p "Введи длину пароля:" pass_len && echo $(< /dev/urandom tr -dc 'A-Za-z0-9' | head -c"$pass_len")
