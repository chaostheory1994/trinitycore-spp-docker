FROM debian:10.10 as buildStep

RUN apt-get update && apt-get install git clang cmake make gcc g++ libmariadbclient-dev libssl-dev libbz2-dev libreadline-dev libncurses-dev libboost-all-dev mariadb-server p7zip default-libmysqlclient-dev -y
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang 100

COPY ./TrinityCore /src
COPY ./custom_script_loader.cpp /src/server/scripts/Custom
COPY ./mod-bg-reward/src/BGReward_SC.cpp /src/server/scripts/Custom
COPY ./Solocraft/Solocraft.cpp /src/server/scripts/Custom
COPY ./AzerothCore-Content/Modules/mod-randomenchants/src/mod_randomenchants.cpp /src/server/scripts/Custom
COPY ./AzerothCore-Content/Modules/mod-moneyforkills/src/mod_moneyforkills.cpp /src/server/scripts/Custom
WORKDIR /src/build

RUN cmake /src -DSCRIPTS="dynamic" -DCMAKE_INSTALL_PREFIX=/output/bin -DCONF_DIR=/output/etc
RUN make -j$(nproc) && make install
