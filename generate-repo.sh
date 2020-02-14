sudo apt update
sudo apt-get install dpkg-dev apache2 dpkg-sig
/etc/init.d/apache2 start

cd /var/www/html
mkdir debs 
rm -r InRelease ${KEYNAME}.gpg Packages Packages.gz Release Release.gpg
rm -r ~/.gnupg/
mkdir ~/.gnupg/
chown -R $(whoami) ~/.gnupg/
find ~/.gnupg -type f -exec chmod 600 {} \;
find ~/.gnupg -type d -exec chmod 700 {} \;

echo "cert-digest-algo SHA256" >> ~/.gnupg/gpg.conf
echo "digest-algo SHA256" >> ~/.gnupg/gpg.conf

gpg --gen-key
gpg --list-keys
gpg --output ${KEYNAME}.gpg --armor --export $KEYID
dpkg-sig --sign debs/*.deb

apt-ftparchive packages debs > Packages
dpkg-scanpackages debs /dev/null | gzip -9c > Packages.gz
apt-ftparchive release debs > Release

gpg --clearsign -o InRelease Release
gpg -abs -o Release.gpg Release

echo "deb http://127.0.0.1 /" | sudo tee -a /etc/apt/sources.list
wget -q -O - http://127.0.0.1/${KEYNAME}.gpg | sudo apt-key add -
apt update
