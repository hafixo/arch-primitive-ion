#!/usr/bin/env bash
#
# @@script: primitive-ion.sh
# @@description: package manifest for Docker Container
# @@author: Loouis Low <loouis@gmail.com>
# @@copyright: EVAC Laboratories (dogsbark.net)
#

######## vars ##########

# path
fullPath="/home/$USER/Documents/play/playground/arch-primitive-ion"

# ansi
blue='\e[94m'
red='\e[91m'
dgray='\e[90m'
nc='\033[0m'
bold=$(tput bold)
normal=$(tput sgr0)
title="${blue}[arch]${nc}"

mem_threshold="1024"

function runas_root() {
  # check if sudo
  if [ "$(whoami &2> /dev/null)" != "root" ] &&
     [ "$(id -un &2> /dev/null)" != "root" ]
    then
      echo -e "$title permission denied"
      exit 1
  fi
}

function prerequisites() {
  if which mvn > /dev/null;
    then
      echo -e "$title everything is fine. (OK)"
    else
      # install components
      echo -e "$title installing >> JDK, Maven"
      apt-get --force-yes --yes install default-jdk maven
  fi
}

function die() {
  echo -e $*
  exit 1
}

function clean_build() {
  echo -e "$title preparing compiler..."
  mvn clean; mvn install -e

  echo -e "${blue}"; cd $fullPath
  mvn package -Dmaven.test.skip=true || die "$title ${red}[err]${normal} could not package!"
}

function clean_package() {
  echo -e "$title clean package completely..."
  mvn clean; mvn -o clean
}

function run_package() {
  jar=`find $fullPath/target/arch-primitive-ion*-SNAPSHOT-evaclabs.jar`
  cp=`echo $jar`

  javaArgs="-server -XX:+HeapDumpOnOutOfMemoryError -Xmx${mem_threshold}m -jar "$cp" $*"

  echo -e "$title >> running using Java on path at ${bold}`which java`${normal} with args ${bold}$javaArgs${normal}"
  echo -e "${dgray}--->> accesslog >>----------------------------------------------------------"

  java $javaArgs || die "$title ${red}[err]${normal} java process exited abnormally!"
}

function check_systemd() {
  # Check if this system is running systemd
  if [[ $(ps --no-headers -o comm 1) = systemd ]]
    then
      echo -e"$title component >> systemd (OK)";echo
    else
      echo -e "$title supports only >> systemd. EXIT!";echo
      exit -1
  fi
}

function create_user() {
  # Create user 'archprimitive'
  echo -e "$titile creating user >> 'archprimitive'"
  useradd -m archprimitive
  echo -e "$titile creating user >> OK";echo
}

function create_appdir() {
  # Create application dir
  echo -e "$title creating app folder >> /opt/arch-primitive-ion"
  mkdir -p /opt/arch-primitive-ion
  chown -R archprimitive:archprimitive /opt/arch-primitive-ion
  echo -e "$title creating app folder >> OK";echo
}

function check_app_service() {
  # Stop the service if already is running on this host
  if [[ $(systemctl is-active archprimitive.service) = active ]]; then
    echo -e "$title service is running >> stopping..."
    systemctl stop archprimitive.service
    echo -e "$title stopping service >> OK";echo
  fi
}

function create_service_script() {
  # Create service script file
  echo -e "$title create service >> description"

  SERVICE_FILE="/etc/systemd/system/archprimitive.service"

  echo -e "[Unit]" > $SERVICE_FILE
  echo -e "Description=Arch Primitive Ion" >> $SERVICE_FILE
  echo -e "After=syslog.target network.target" >> $SERVICE_FILE
  echo "" >> $SERVICE_FILE
  echo -e "[Service]" >> $SERVICE_FILE
  echo -e "User=archprimitive" >> $SERVICE_FILE
  echo -e "ExecStart=/usr/bin/java -jar /opt/arch-primitive-ion/arch-primitive-ion-0.9.7.5-SNAPSHOT.jar" >> $SERVICE_FILE
  echo -e "Restart=on-failure" >> $SERVICE_FILE
  echo -e "SuccessExitStatus=143" >> $SERVICE_FILE
  echo "" >> $SERVICE_FILE
  echo -e "[Install]" >> $SERVICE_FILE
  echo -e "WantedBy=multi-user.target" >> $SERVICE_FILE
  echo "" >> $SERVICE_FILE
  echo -e "$title create service >> OK";echo
}

function moveto_appdir() {
  # Compile from source and move to app folder /opt/archprimitive-ion
  cp -f target/arch-primitive-ion-0.9.7.5-SNAPSHOT.jar /opt/archprimitive-ion/arch-primitive-ion-0.9.7.5-SNAPSHOT.jar
  chown -R archprimitive:archprimitive /opt/archprimitive-ion
}

function start_app_service() {
  echo -e "$title service permission >> set"
  chmod 664 /etc/systemd/system/archprimitive.service
  echo -e "$title service permission >> OK";echo

  echo -e "$title daemon >> reloading"
  systemctl daemon-reload
  echo -e "$title daemon >> OK";echo

  echo -e "$title service >> enabling"
  systemctl enable archprimitive.service
  echo -e "$title service >> OK";echo

  # Check that service is installed and enabled
  if [[ $(systemctl is-enabled archprimitive.service) != enabled ]]; then
    echo -e "$title ERR >> check for error messages.";echo
    exit -1
  fi

  # Start the service
  echo -e "$title init service >> starting"
  systemctl start archprimitive.service

  sleep 5

  if [[ $(systemctl is-active archprimitive.service) != active ]]; then
    echo -e "$title ERR >> check for error messages.";echo
    exit -1
  fi

  echo -e "$title init service >> started"
  echo -e "$title gui >> http://localhost:8080"
  echo -e "$title server >> (ipaddress, 127.0.0.1, 0.0.0.0, localhost):(<port, 3129)"
  echo
}

######## init ##########

echo -e "${blue}-------------------------------------------------------------------------------"
echo -e " ARCH {primitive} Ion : Ultra High Performance Network Relay"
echo -e "-------------------------------------------------------------------------------${nc}"

while test "$#" -gt 0;
  do
    case "$1" in

      -h|--help)
      shift
        echo
        echo -e " ${bold}Usage:${normal}"
        echo
        echo "  -h, --help          Display this information"
        echo "  -b, --build         Build the package"
        echo "  -c, --clean         Clean the package"
        echo "  -r, --run           Run the package"
        echo "  -i, --install       Install package"
        echo
        exit 1
      shift;;

      -b|--build)
      shift
        prerequisites
        clean_build
      shift;;

      -c|--clean)
      shift
        prerequisites
        clean_package
      shift;;

      -r|--run)
      shift
        prerequisites
        run_package
      shift;;

      -i|--install)
      shift
        runas_root
        prerequisites
        check_systemd
        create_user
        create_appdir
        check_app_service
        create_service_script
        clean_package
        clean_build
        moveto_appdir
        start_app_service
      shift;;

      *) break;;

  esac
done
