#! /bin/bash

MONGODB_TOOLKIT=$(echo ${STREAMS_STUDIO_SPL_PATH} | grep -oP '/[^:]*com.ibm.streamsx.mongodb')

if [[ ! -L $MONGODB_TOOLKIT/impl/include/boost ]]; then
	ln -s $STREAMS_INSTALL/ext/include/streams_boost $MONGODB_TOOLKIT/impl/include/boost
fi
