adduser sdrpa
usermod -aG sudo sdrpa

sudo apt-get update && sudo apt-get -y upgrade

wget https://swift.org/builds/swift-4.0.2-release/ubuntu1604/swift-4.0.2-RELEASE/swift-4.0.2-RELEASE-ubuntu16.04.tar.gz
tar xzf swift-4.0.2-RELEASE-ubuntu16.04.tar.gz
rm -f swift-4.0.2-RELEASE-ubuntu16.04.tar.gz
sudo mv swift-4.0.2-RELEASE-ubuntu16.04 /usr/local
echo 'export PATH=/usr/local/swift-4.0.2-RELEASE-ubuntu16.04/usr/bin:$PATH' >> ~/.profile
source .profile
which swift

sudo apt-get update
sudo apt-get install clang
sudo apt-get install libpython2.7
sudo apt-get install libcurl3
sudo apt-get install libcurl4-openssl-dev
sudo apt-get install libpq-dev
sudo apt-get install postgresql

swift build -Xcc -I/usr/include/postgresql

sudo nano /etc/postgresql/9.5/main/pg_hba.conf
sudo service postgresql restart

sudo apt-get install python-software-properties
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install nodejs

sudo apt-get install nginx
sudo ufw allow ssh
sudo ufw app list
sudo ufw allow 'Nginx HTTP'

https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-16-04