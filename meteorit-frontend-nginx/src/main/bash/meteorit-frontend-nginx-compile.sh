#!/bin/bash

cd '${nginx.sourcefolder_}'
#if [ -e objs/nginx ]; then
#	echo 'Nginx already built, skipping'
#	exit 0
#fi

echo 'Starting nginx build...'


echo 'Configuring:'

# add LuaJIT environment
export LUAJIT_LIB=${install.prefix_}/lj2/lib
export LUAJIT_INC=${install.prefix_}/lj2/include/luajit-2.0

if [[ ! -d "$LUAJIT_LIB" || ! -d "" ]]; then

fi

./configure --prefix='${nginx.installfolder_}' \
			--add-module='${redis2-module.sourcefolder_}/' \
			--add-module='${nginx-devel-kit.sourcefolder_}' \
			--add-module='${nginx-lua-module.sourcefolder_}' \
			--user='${nginx.username_}'\
			--group='${nginx.groupname_}' | pv -f -l -p -s 122 > ./configure.output
ERR_=$?
if [ $ERR_ -ne 0 ]; then
	echo "Error configuring, checkout 'configure.output'"
	exit $ERR_
fi
echo 'Compiling:'
make | pv -l -f -p -s 641 > ./make.output
ERR_=$?
if [ $ERR_ -ne 0 ]; then
	echo "Error running make, checkout 'make.output'"
	exit $ERR_
fi

# the make install script uses a prefix DESTDIR environment variable which we use to create a complete temp install
DESTDIR='${nginx.tempfolder_}' make install

echo 'Modifying configuration...'
sed -i  -e 's/^#user.*nobody;/user ${nginx.username_};/' ${nginx.tempfolder_}/${nginx.installfolder_}/conf/nginx.conf

echo 'Completed'