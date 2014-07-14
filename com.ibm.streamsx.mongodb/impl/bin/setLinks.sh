#! /bin/bash

if [[ ! -L ../../impl/lib/libboost_filesystem-mt.so ]]; then
	ln -s libboost_filesystem-mt.so.5 ../../impl/lib/libboost_filesystem-mt.so
fi

if [[ ! -L ../../impl/lib/libboost_system-mt.so ]]; then
	ln -s libboost_system-mt.so.5 ../../impl/lib/libboost_system-mt.so
fi

if [[ ! -L ../../impl/lib/libboost_thread-mt.so ]]; then
	ln -s libboost_thread-mt.so.5 ../../impl/lib/libboost_thread-mt.so
fi
