FROM debian:10.10 as buildStep

RUN apt-get update && apt-get install git clang cmake make gcc g++ libmariadbclient-dev libssl-dev libbz2-dev libreadline-dev libncurses-dev libboost-all-dev mariadb-server p7zip default-libmysqlclient-dev -y
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang 100

COPY . /src
WORKDIR /src/build

RUN cmake /src -DSCRIPTS="dynamic" -DCMAKE_INSTALL_PREFIX=/output/bin -DCONF_DIR=/output/etc
RUN make -j$(nproc) && make install
