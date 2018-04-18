#!/bin/bash
#
# @@script: link.sh
# @@description: forward traffic to relay connection
# @@version: 0.0.0.1
# @@author: Loouis Low
# @@copyright: EVAC Laboratories (dogsbark.net)
#

######## vars ##########

# ansi
blue='\e[94m'
green='\e[92m'
red='\e[91m'
dgray='\e[90m'
nc='\033[0m'
bold=$(tput bold)
normal=$(tput sgr0)
tag='\e[100m'
title="${blue}[arch]${nc}"
error="${red}[error]${nc}"

# network interfaces
device1="wlp4s0"
device2="enp3s0"
bridge="docker0"

# ruler
policier="/sbin/iptables"

# from ports
http_port_from="80"
https_port_from="443"

# to relay ports
http_port_to="7878"
https_port_to="7878"

# router
router_gateway="192.168.182.1"

# enable ip forward
ip_forward_mode="1"
ip_forward="sysctl net.ipv4.ip_forward=${ip_forward_mode}"

###### functions #######

function runas_root() {
  # check if sudo
  if [ "$(whoami &2> /dev/null)" != "root" ] &&
     [ "$(id -un &2> /dev/null)" != "root" ]
    then
      echo -e "$title $error permission denied"
      exit 1
  fi
}

function prerequisites() {
  # check iptables installed
  if which iptables > /dev/null;
    then
      echo -e "$title ${policier} (OK)"
    else
      # install iptables package
      echo -e "$title installing iptables"
      apt install -y \
        iptables \
        iptables-persistent
  fi
}

function reset_rules() {
  echo -e "$title reset policies"

  # clean obsolete rules
  ${policier} -F
  ${policier} -X
  ${policier} -t nat -F
  ${policier} -t nat -X
  ${policier} -t mangle -F
  ${policier} -t mangle -X
  ${policier} -t nat -F PREROUTING
}

function restore_rules() {
  echo -e "$title restore default policies"

  # reset the default policies in the filter table.
  ${policier} -P INPUT ACCEPT
  ${policier} -P FORWARD ACCEPT
  ${policier} -P OUTPUT ACCEPT

  # reset the default policies in the nat table.
  ${policier} -t nat -P PREROUTING ACCEPT
  ${policier} -t nat -P POSTROUTING ACCEPT
  ${policier} -t nat -P OUTPUT ACCEPT

  # reset the default policies in the mangle table.
  ${policier} -t mangle -P PREROUTING ACCEPT
  ${policier} -t mangle -P POSTROUTING ACCEPT
  ${policier} -t mangle -P INPUT ACCEPT
  ${policier} -t mangle -P OUTPUT ACCEPT
  ${policier} -t mangle -P FORWARD ACCEPT

  # flush all the rules in the filter and nat tables.
  ${policier} -F
  ${policier} -t nat -F
  ${policier} -t mangle -F

  # erase all chains that's not default in filter and nat table.
  ${policier} -X
  ${policier} -t nat -X
  ${policier} -t mangle -X
}

function policy_filters() {
  echo -e "$title add new policies"

  # reset the default policies in the filter table.
  ${policier} -P INPUT ACCEPT
  ${policier} -P FORWARD ACCEPT
  ${policier} -P OUTPUT ACCEPT

  # unlimited access to loop back
  ${policier} -A INPUT -i lo -j ACCEPT
  ${policier} -A OUTPUT -o lo -j ACCEPT

  # allow UDP, DNS and Passive FTP
  # //////// WLAN ////////
  ${policier} -A INPUT -i ${device1} -m state --state ESTABLISHED,RELATED -j ACCEPT

  # enable IPV4 forwarding
  echo -e "$title ip-forward mode: ${ip_forward}"

  # OPEN everything
  # //////// WLAN ////////
  ${policier} -A INPUT -i ${device1} -j ACCEPT
  ${policier} -A OUTPUT -o ${device1} -j ACCEPT

  # add docker rules
  docker_rules

  # do not log smb/windows sharing packets - too much logging
  # //////// WLAN ////////
  ${policier} -A INPUT -p tcp -i ${device1} --dport 137:139 -j REJECT
  ${policier} -A INPUT -p udp -i ${device1} --dport 137:139 -j REJECT

  # log everything else and drop
  ${policier} -A INPUT -j LOG
  ${policier} -A FORWARD -j LOG
  ${policier} -A INPUT -j DROP
}

function docker_rules() {
  echo -e "$title add docker policies"

  # forward chain between docker0 and network interface
  ${policier} -A FORWARD -i ${bridge} -o ${device1} -j ACCEPT
  ${policier} -A FORWARD -i ${device1} -o ${bridge} -j ACCEPT

  # IPv6 chain if needed
  ${policier} -A FORWARD -i ${bridge} -o ${device1} -j ACCEPT
  ${policier} -A FORWARD -i ${device1} -o ${bridge} -j ACCEPT
}

function intercept_network() {
  # Forward traffic to ARCH relay port
  # //////// WLAN ////////
  # (http)
  echo -e "$title intercept device ${device1} port ${http_port_from} to ${http_port_to}"
  ${policier} -t nat -A PREROUTING -i ${device1} -p tcp --dport ${http_port_from} -j REDIRECT --to-port ${http_port_to}
  ${policier} -A FORWARD -i ${device1} -p tcp --dport ${http_port_from} -j ACCEPT
  ${policier} -t nat -A POSTROUTING -o ${device1} -p tcp --dport ${http_port_from} -j MASQUERADE
  # (https)
  echo -e "$title intercept device ${device1} port ${https_port_from} to ${https_port_to}"
  ${policier} -t nat -A PREROUTING -i ${device1} -p tcp --dport ${https_port_from} -j REDIRECT --to-port ${https_port_to}
  ${policier} -A FORWARD -i ${device1} -p tcp --dport ${https_port_from} -j ACCEPT
  ${policier} -t nat -A POSTROUTING -o ${device1} -p tcp --dport ${https_port_from} -j MASQUERADE
}

function restart_arch() {
  echo -e "$title restart docker services"
  service docker restart
  echo -e "$title restart arch-primitive-ion container"
  docker run -it -p ${http_port_to} loouislow81/arch-primitive-ion
}

function show_statistics() {
  echo "----/ Details /--------------------"
  echo "WLAN: $device1"
  echo "LAN: $device2"
  echo "VLAN: $bridge"
  echo "-----------------------------------"
  echo "HTTP Port From: $http_port_from"
  echo "HTTPS Port From: $https_port_from"
  echo "-----------------------------------"
  echo "HTTP Port To: $http_port_to"
  echo "HTTPS Port To: $https_port_to"
  echo "-----------------------------------"
}

######## init ########

BINARY=$(basename $0)
echo -e "$title usage: $BINARY --help"

while test "$#" -gt 0;
do
  case "$1" in

    -h|--help)
    echo
    echo "${bold}Usage:${normal}"
    echo
    echo "  -h, --help                Display this infomation"
    echo "  -i, --intercept           Intercept all traffic"
    echo "  -a, --alt--intercept      Alternative Intercept"
    echo "  -r, --restore             Restore default policies"
    echo "  -i, --info                Technical Details"
    echo
    exit 0;;

    -i|--intercept)
    shift
      runas_root
      prerequisites
      restore_rules
      reset_rules
      policy_filters
      intercept_network
      show_statistics
    shift;;

    -a|--alt-intercept)
    shift
      runas_root
      prerequisites
      restore_rules
      reset_rules
      policy_filters
      alternative_intercept
      show_statistics
    shift;;

    -r|--restore)
    shift
      runas_root
      prerequisites
      restore_rules
    shift;;

    -rs|--restart)
    shift
      runas_root
      restart_arch
    shift;;

    -i|--info)
    shift
      show_statistics
    shift;;

    *) break;;

  esac
done
