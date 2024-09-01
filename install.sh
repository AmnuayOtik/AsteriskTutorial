#!/bin/bash

# Function to check if the script is run as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run this script as root or using sudo."
        exit 1
    fi
}

# Function to check if the OS is Ubuntu 20.04
check_os_version() {
    os_version=$(lsb_release -r | awk '{print $2}')
    if [ "$os_version" != "20.04" ]; then
        echo "This script is designed to run on Ubuntu 20.04 only."
        exit 1
    fi
}

# Function to check if the server is in the specified network
check_network() {
    current_ip=$(hostname -I | awk '{print $1}')
    if [[ "$current_ip" == 192.168.98.* ]]; then
        echo "Server is in the 192.168.98.0/24 network."
        export http_proxy="http://192.168.98.53:3128"
        echo "HTTP proxy set to: $http_proxy"
    else
        echo "Server is not in the 192.168.98.0/24 network."
    fi
}

# Check if the script is run as root
echo "Checking for root permissions..."
check_root
echo "Root permissions verified."

# Check if the OS version is Ubuntu 20.04
echo "Checking OS version..."
check_os_version
echo "OS version is Ubuntu 20.04. Proceeding with installation."

# Display current IP address
current_ip=$(hostname -I | awk '{print $1}')
echo "Current IP address: $current_ip"

# Check if server is in the specified network
#check_network

# Update and upgrade packages
echo "Updating and upgrading packages..."
apt-get -y update
apt-get -y upgrade

# Check and set timezone to Asia/Bangkok if necessary
current_timezone=$(timedatectl show --property=Timezone --value)
if [ "$current_timezone" != "Asia/Bangkok" ]; then
    echo "Setting timezone to Asia/Bangkok..."
    timedatectl set-timezone Asia/Bangkok
fi

# Install ntpdate and sync time
echo "Installing ntpdate and syncing time..."
apt install -y ntpdate
ntpdate ntp.ku.ac.th

# Install required packages
echo "Installing required packages..."
apt-get -y install nano build-essential git curl wget libnewt-dev libssl-dev libncurses5-dev subversion \
libsqlite3-dev libjansson-dev libxml2-dev uuid-dev default-libmysqlclient-dev \
htop sngrep lame ffmpeg mpg123 \
git vim curl wget libnewt-dev libssl-dev libncurses5-dev \
libsqlite3-dev build-essential libjansson-dev \
libxml2-dev uuid-dev expect

# Install web server packages
echo "Installing web server packages..."
apt-get -y install build-essential linux-headers-$(uname -r) openssh-server apache2 mariadb-server \
mariadb-client bison flex php7.4 php7.4-curl php7.4-cli php7.4-common \
php7.4-mysql php7.4-mbstring php7.4-gd php7.4-intl php7.4-xml \
php-pear curl sox libncurses5-dev libssl-dev mpg123 libxml2-dev \
libnewt-dev sqlite3 libsqlite3-dev pkg-config automake libtool \
autoconf git unixodbc-dev uuid uuid-dev libasound2-dev libogg-dev \
libvorbis-dev libicu-dev libcurl4-openssl-dev odbc-mariadb libical-dev \
libneon27-dev libsrtp2-dev libspandsp-dev sudo subversion libtool-bin \
python-dev-is-python3 unixodbc vim wget libjansson-dev \
software-properties-common nodejs npm ipset iptables fail2ban php-soap \
odbc-mariadb

# Install Asterisk
echo "Downloading Asterisk..."
cd /usr/src
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-21-current.tar.gz
if [ $? -ne 0 ]; then
    echo "Download Asterisk failed"
    exit 1
fi
tar zxvf asterisk-21-current.tar.gz
rm -rf asterisk-21-current.tar.gz
cd asterisk-21*/
contrib/scripts/install_prereq install
./configure --libdir=/usr/lib64 --with-pjproject-bundled --with-jansson-bundled

# Compilation and installation
echo "Compiling and installing Asterisk..."
make menuselect.makeopts

menuselect/menuselect \
--enable chan_mobile \
--enable chan_ooh323 \
--enable format_mp3 \
--enable res_config_mysql \
--enable app_macro \
--enable CORE-SOUNDS-EN-WAV \
--enable CORE-SOUNDS-EN-ULAW \
--enable CORE-SOUNDS-EN-ALAW \
--enable CORE-SOUNDS-EN-GSM \
--enable CORE-SOUNDS-EN-G729 \
--enable CORE-SOUNDS-EN-G722 \
--enable CORE-SOUNDS-EN-SLN16 \
--enable CORE-SOUNDS-EN-SIREN7 \
--enable CORE-SOUNDS-EN-SIREN14 \
--enable MOH-OPSOUND-WAV \
--enable MOH-OPSOUND-ULAW \
--enable MOH-OPSOUND-ALAW \
--enable MOH-OPSOUND-GSM \
--enable MOH-OPSOUND-G729 \
--enable MOH-OPSOUND-G722 \
--enable MOH-OPSOUND-SLN16 \
--enable MOH-OPSOUND-SIREN7 \
--enable MOH-OPSOUND-SIREN14 \
--enable EXTRA-SOUNDS-EN-WAV \
--enable EXTRA-SOUNDS-EN-ULAW \
--enable EXTRA-SOUNDS-EN-ALAW \
--enable EXTRA-SOUNDS-EN-GSM \
--enable EXTRA-SOUNDS-EN-G729 \
--enable EXTRA-SOUNDS-EN-G722 \
--enable EXTRA-SOUNDS-EN-SLN16 \
--enable EXTRA-SOUNDS-EN-SIREN7 \
--enable EXTRA-SOUNDS-EN-SIREN14 \
 menuselect.makeopts

make
contrib/scripts/get_mp3_source.sh
make install
make samples

# Check if the /etc/asterisk/samples directory exists, if not, create it
echo "Checking and creating /etc/asterisk/samples directory if necessary..."
if [ ! -d /etc/asterisk/samples ]; then
    mkdir /etc/asterisk/samples
fi

echo "Moving sample configuration files..."
mv /etc/asterisk/*.* /etc/asterisk/samples/
make basic-pbx
make config

# Enable Asterisk service
echo "Enabling Asterisk service..."
systemctl enable asterisk

# Create asterisk user and set permissions
echo "Creating Asterisk user and setting permissions..."
groupadd asterisk
useradd -r -d /var/lib/asterisk -g asterisk asterisk
usermod -aG audio,dialout asterisk
chown -R asterisk:asterisk /etc/asterisk
chown -R asterisk:asterisk /var/{lib,log,spool}/asterisk
chown -R asterisk:asterisk /usr/lib64/asterisk

# Update Asterisk configuration files
echo "Updating Asterisk configuration files..."
sed -i 's|#AST_USER|AST_USER|' /etc/default/asterisk
sed -i 's|#AST_GROUP|AST_GROUP|' /etc/default/asterisk
sed -i 's|;runuser|runuser|' /etc/asterisk/asterisk.conf
sed -i 's|;rungroup|rungroup|' /etc/asterisk/asterisk.conf
echo "/usr/lib64" >> /etc/ld.so.conf.d/x86_64-linux-gnu.conf
ldconfig

# Start Asterisk services
echo "Start Asterisk services"
systemctl start asterisk

# Add custom message to /etc/motd
echo "Adding custom message to /etc/motd..."
cat << 'EOF' > /etc/motd

  _____  ______   __ _______     _______ _______ ______ __  __
 |  __ \|  _ \ \ / // ____\ \   / / ____|__   __|  ____|  \/  |
 | |__) | |_) \ V /| (___  \ \_/ / (___    | |  | |__  | \  / |
 |  ___/|  _ < > <  \___ \  \   / \___ \   | |  |  __| | |\/| |
 | |    | |_) / . \ ____) |  | |  ____) |  | |  | |____| |  | |
 |_|    |____/_/ \_\_____/   |_| |_____/   |_|  |______|_|  |_|


Welcome to pbxsystem | By OtikNetwork
www.otiknetwork.com / 02-538-4378, 095-549-9819

EOF

echo "Asterisk installation completed successfully."

