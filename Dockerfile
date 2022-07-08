FROM debian:latest

RUN dpkg --add-architecture i386 \
	&& apt-get -qq update \
	&& apt-get -qq upgrade -y \
	&& apt-get -qq install -y \
		ca-certificates \
		wget \
		g++-multilib \
		make \
		git \
		unzip \
		vim \
		less \
		man \
		libssl-dev:i386 \
		libmariadb-dev:i386

# CMake
RUN \ 
	CMAKE_VERSION=3.24.0-rc3 && \ 
	mkdir -p /tmp/cmake && \ 
	wget -q -O /tmp/cmake/cmake.sh https://cmake.org/files/v`expr "$CMAKE_VERSION" : '\([0-9][0-9]*\.[0-9][0-9]*\)'`/cmake-${CMAKE_VERSION}-linux-x86_64.sh && \ 
	chmod +x /tmp/cmake/cmake.sh && \ 
	./tmp/cmake/cmake.sh --prefix=/usr/local --exclude-subdir && \ 
	rm -rf /tmp/cmake

# Boost
RUN \ 
	BOOST_VERSION=1.79.0 && \ 
	mkdir -p /tmp/boost && \ 
	wget -q -O /tmp/boost/boost.tar.gz https://boostorg.jfrog.io/artifactory/main/release/${BOOST_VERSION}/source/boost_`echo $BOOST_VERSION | sed 's|\.|_|g'`.tar.gz && \ 
	tar xfz /tmp/boost/boost.tar.gz -C /tmp/boost/ --strip-components=1 && \ 
	cd /tmp/boost && \ 
	./bootstrap.sh --prefix=/usr/local --with-libraries=system,chrono,thread,regex,date_time,atomic && \ 
	./b2 variant=release link=static threading=multi address-model=32 runtime-link=shared -j2 -d0 install && \ 
	cd - && \ 
	rm -rf /tmp/boost

# open.mp server + includes
RUN \ 
	mkdir -p /tmp/samp && \ 
	wget -q -O /tmp/samp/open.mp-linux.tar.gz https://github.com/openmultiplayer/server-beta/releases/download/build5/open.mp-linux.tar.gz && \ 
	tar xfz /tmp/samp/open.mp-linux.tar.gz -C /root/ && \ 
	wget -q -O /tmp/samp/samp-stdlib.zip https://github.com/pawn-lang/samp-stdlib/archive/refs/heads/master.zip && \ 
	unzip /tmp/samp/samp-stdlib.zip *.inc -d /root/samp03 && \ 
	wget -q -O /tmp/samp/pawn-stdlib.zip https://github.com/pawn-lang/pawn-stdlib/archive/refs/heads/master.zip && \ 
	unzip /tmp/samp/pawn-stdlib.zip *.inc -d /root/samp03 && \ 
	rm -rf /tmp/samp

# PAWN compiler
RUN \ 
	PAWN_COMPILER_VERSION=3.10.10 && \ 
	mkdir -p /tmp/pawncc && \ 
	wget -q -O /tmp/pawncc/pawncc.tar.gz https://github.com/pawn-lang/compiler/releases/download/v${PAWN_COMPILER_VERSION}/pawnc-${PAWN_COMPILER_VERSION}-linux.tar.gz && \ 
	tar xfz /tmp/pawncc/pawncc.tar.gz -C /usr/local/ --strip-components=1 && \ 
	ldconfig && \ 
	rm -rf /tmp/pawncc

WORKDIR /root
CMD ["/bin/bash"]
