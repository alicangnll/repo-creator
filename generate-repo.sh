#!/bin/sh
clear
echo Durum: 200 Okay
echo Content-Type: text/plain
echo ---------------------------------
echo Gerekli Dosyalar Kuruluyor
echo ---------------------------------

sudo apt update
sudo apt-get install dpkg-dev apache2 dpkg-sig
/etc/init.d/apache2 start

clear
echo ---------------------------------
echo Konum Ve GPG Geçmişi Siliniyor
echo ---------------------------------

cd /var/www/html
mkdir debs 
rm -r InRelease FileName.gpg Packages Packages.gz Release Release.gpg
rm -r ~/.gnupg/
mkdir ~/.gnupg/
chown -R $(whoami) ~/.gnupg/
find ~/.gnupg -type f -exec chmod 600 {} \;
find ~/.gnupg -type d -exec chmod 700 {} \;

echo "cert-digest-algo SHA256" >> ~/.gnupg/gpg.conf
echo "digest-algo SHA256" >> ~/.gnupg/gpg.conf

clear
echo ---------------------------------
echo GPG Başlıyor
echo ---------------------------------

gpg --list-keys
gpg --gen-key
gpg --output FileName.gpg --armor --export $KEYID
dpkg-sig --sign debs/*.deb


echo ---------------------------------
echo Repo Kaydı Yapılıyor
echo ---------------------------------

apt-ftparchive packages debs > Packages
gzip -c Packages > Packages.gz
apt-ftparchive release debs > Release

gpg --clearsign -o InRelease Release
gpg -abs -o Release.gpg Release

clear
echo ---------------------------------
echo Repo Ekleniyor
echo ---------------------------------

echo "deb http://127.0.0.1 /" | sudo tee -a /etc/apt/sources.list
wget -q -O - http://127.0.0.1/FileName.gpg | sudo apt-key add -
apt update

clear
echo ---------------------------------
cat /etc/apt/sources.list
echo ---------------------------------
echo Kontrol Ediniz !!
echo ---------------------------------
