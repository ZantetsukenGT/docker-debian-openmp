FROM debian:latest

WORKDIR /root

RUN dpkg --add-architecture i386 \
	&& apt-get -qq update \
	&& apt-get -qq upgrade -y \
	&& apt-get -qq install -y \
		ca-certificates \
		wget \
		curl \
		g++-multilib \
		make \
		git \
		zip \
		unzip \
		vim \
		less \
		man \
		pkg-config \
		libmariadb-dev:i386 \
		linux-headers-$(uname -r)

# CMake
RUN \ 
	CMAKE_VERSION=3.24.0-rc3 && \ 
	mkdir -p /tmp/cmake && \ 
	wget -q -O /tmp/cmake/cmake.sh https://cmake.org/files/v`expr "$CMAKE_VERSION" : '\([0-9][0-9]*\.[0-9][0-9]*\)'`/cmake-${CMAKE_VERSION}-linux-x86_64.sh && \ 
	chmod +x /tmp/cmake/cmake.sh && \ 
	/tmp/cmake/cmake.sh --prefix=/usr/local --exclude-subdir && \ 
	rm -rf /tmp/cmake

# vcpkg - install vcpkg, add to path and create a linux x86 static triplet file
ENV PATH=$PATH:/root/vcpkg
RUN git clone https://github.com/Microsoft/vcpkg && \
    cd vcpkg && \
    ./bootstrap-vcpkg.sh && \
    touch triplets/x86-linux-static.cmake && \
    echo "set(VCPKG_TARGET_ARCHITECTURE x86)" >> triplets/x86-linux-static.cmake && \
    echo "set(VCPKG_CRT_LINKAGE static)" >> triplets/x86-linux-static.cmake && \
    echo "set(VCPKG_LIBRARY_LINKAGE static)" >> triplets/x86-linux-static.cmake && \
    echo "set(VCPKG_CMAKE_SYSTEM_NAME Linux)" >> triplets/x86-linux-static.cmake && \
    cd ..

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

CMD ["/bin/bash"]
