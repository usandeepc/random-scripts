#sudo apt-mirror

cd /var/spool/apt-mirror/mirror/cdn-fastly.deb.debian.org/debian/dists/

for master_directory in buster buster-updates buster-backports; do
    cd $master_directory

    for directory in contrib main non-free; do
        cd $directory
        mkdir i18n 2>/dev/null
        cd i18n
        rm Translation-en*
        wget http://cdn-fastly.deb.debian.org/debian/dists/$master_directory/$directory/i18n/Translation-en.xz
        wget http://cdn-fastly.deb.debian.org/debian/dists/$master_directory/$directory/i18n/Translation-en.bz2
        cd ../../
    done

    cd ..
done

cd /var/spool/apt-mirror/mirror/cdn-fastly.deb.debian.org/debian-security/dists/
for master_directory in stable/updates; do
    cd $master_directory

    for directory in contrib main non-free; do
        cd $directory
        mkdir i18n 2>/dev/null
        cd i18n
        rm Translation-en*
        wget http://cdn-fastly.deb.debian.org/debian-security/dists/stable/updates/$directory/i18n/Translation-en.xz
        wget http://cdn-fastly.deb.debian.org/debian-security/dists/stable/updates/$directory/i18n/Translation-en.bz2
        cd ../../
    done

    cd ..


done
~                                                                                                                                                                       
~        
