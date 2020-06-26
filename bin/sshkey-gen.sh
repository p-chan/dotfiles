#!/bin/bash

# Usage:
#   sh ssh-keygen.sh hostname

hostname=$1
dirname=~/.ssh/conf.d/${hostname}.conf

if [ ! $hostname ]; then
  echo "Please input hostname"
  exit 1
fi

# Check target directory path
if [ -d $dirname ]; then
  echo "Already exists"
  exit 1
fi

# Create a　new directory
mkdir -p $dirname

# Create README.md
{
  echo "# ${hostname}"
  echo ""
  echo "> Lorem ipsum..."
} >> ${dirname}/README.md

# Create config
{
  echo "Host ${hostname} alias"
  echo "  HostName ${hostname}"
  echo "  IdentityFile ~/.ssh/conf.d/${hostname}.conf/id_rsa"
  echo "  User p-chan"
  echo "  Port 22"

} >> ${dirname}/config

# Create secret key and public key (no comment, no path phrase)
ssh-keygen -t rsa -b 4096 -f ${dirname}/id_rsa -C "" -N ""

# Ask to copy public key when pbcopy command is installed
if type "pbcopy" > /dev/null 2>&1
then
  echo "Copy public key to clipboard [Y/n]"
  read needs_copy

  case $needs_copy in
    "" | "Y" | "y" ) cat ${dirname}/id_rsa.pub | pbcopy && echo "Copied";;
    * ) exit 0;;
  esac
fi

