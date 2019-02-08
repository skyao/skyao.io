#!/bin/bash

if [ ! -d "themes" ];then
  echo "No themes directory, create it"
  mkdir themes
fi

if [ -d "themes/academic" ];then
  echo 'Find directoy "themes/academic", update by "git pull"'
  cd themes/academic
  git pull
  cd ../../
else
  echo 'Directoy "themes/academic" not found, do "git clone"'
  git clone https://github.com/skyao/hugo-academic.git themes/academic
  #git clone git@github.com:skyao/hugo-academic-cn.git themes/academic
  #cd themes
  #ln -s ../../hugo-academic academic
  #cd ../
fi



