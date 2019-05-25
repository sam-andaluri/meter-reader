#!/bin/bash
#
# Update software on device
sudo apt-get update
# Install dependencies for rtl-sdr libraries
sudo apt-get install -y cmake build-essential python-pip libusb-1.0-0-dev python-numpy git pandoc
# Clone rtl-sdr repo
git clone git://git.osmocom.org/rtl-sdr.git
# Build rtl-sdr binaries
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
sudo cp ./service/rtltcpd.service /etc/systemd/system
sudo cp ./service/rtlamrd.service /etc/systemd/system/
sudo chmod +x /etc/systemd/system/rtltcpd.service
sudo chmod +x /etc/systemd/system/rtlamrd.service
# Setup services log output dir
sudo chown -R root:adm /home/pi/logs/
sudo cp ./service/rtlamrd.conf /etc/rsyslog.d
sudo cp ./service/rtltcpd.conf /etc/rsyslog.d
# Restart syslog daemon
sudo systemctl restart rsyslog
# Enable rtltcp daemon which feeds rtlamr daemon to autostart on boot
sudo systemctl enable rtltcpd.service
sudo systemctl enable rtlamrd.service
# Start services now
sudo systemctl start rtltcpd.service
sudo systemctl start rtlamrd.service
