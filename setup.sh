#!/bin/bash
#
cd $HOME
# Update software on device
sudo apt-get update
# Install dependencies for rtl-sdr libraries
sudo apt-get install -y cmake build-essential python-pip libusb-1.0-0-dev python-numpy git pandoc
# Clone rtl-sdr repo
git clone git://git.osmocom.org/rtl-sdr.git
# Build rtl-sdr binaries
cd rtl-sdr
mkdir build
cd build
cmake ../ -DINSTALL_UDEV_RULES=ON -DDETACH_KERNEL_DRIVER=ON
make
sudo make install
sudo ldconfig
# Install Golang for rtlamr
cd $HOME
sudo apt-get install -y golang
export GOPATH=$HOME/go
go get github.com/bemasher/rtlamr
export PATH=$PATH:$GOPATH/bin
# Copy service definitions to systemd
sudo curl -o /etc/systemd/system/rtltcpd.service https://raw.githubusercontent.com/sam-andaluri/meter-reader/master/service/rtltcpd.service
sudo curl -o /etc/systemd/system/rtlamrd.service https://raw.githubusercontent.com/sam-andaluri/meter-reader/master/service/rtlamrd.service
sudo chmod +x /etc/systemd/system/rtltcpd.service
sudo chmod +x /etc/systemd/system/rtlamrd.service
# Setup services log output dir
sudo mkdir -p /home/pi/logs/
sudo chown -R root:adm /home/pi/logs/
sudo curl -o /etc/rsyslog.d/rtlamrd.conf https://raw.githubusercontent.com/sam-andaluri/meter-reader/master/service/rtlamrd.conf
sudo curl -o /etc/rsyslog.d/rtltcpd.conf https://raw.githubusercontent.com/sam-andaluri/meter-reader/master/service/rtltcpd.conf
# Restart syslog daemon
sudo systemctl restart rsyslog
# Enable rtltcp daemon which feeds rtlamr daemon to autostart on boot
sudo systemctl enable rtltcpd.service
sudo systemctl enable rtlamrd.service
# Start services now
sudo systemctl start rtltcpd.service
sudo systemctl start rtlamrd.service
