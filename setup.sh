#!/bin/bash
sudo apt-get update
sudo apt-get install -y cmake build-essential python-pip libusb-1.0-0-dev python-numpy git pandoc
git clone git://git.osmocom.org/rtl-sdr.git
mkdir build
cd build
cmake ../ -DINSTALL_UDEV_RULES=ON -DDETACH_KERNEL_DRIVER=ON
make
sudo make install
sudo ldconfig
cd $HOME
sudo apt-get install -y golang
export GOPATH=$HOME/go
go get github.com/bemasher/rtlamr
export PATH=$PATH:$GOPATH/bin
