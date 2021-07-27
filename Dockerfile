FROM debian:10.10 as environment 

RUN apt-get update && apt-get install git clang cmake make gcc g++ libmariadbclient-dev libssl-dev libbz2-dev libreadline-dev libncurses-dev libboost-all-dev mariadb-server p7zip default-libmysqlclient-dev -y
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang 100

FROM environment as buildStep

COPY ./TrinityCore /src
COPY ./custom_script_loader.cpp /src/server/scripts/Custom
COPY ./mod-bg-reward/src/BGReward_SC.cpp /src/server/scripts/Custom
COPY ./Solocraft/Solocraft.cpp /src/server/scripts/Custom
COPY ./AzerothCore-Content/Modules/mod-randomenchants/src/mod_randomenchants.cpp /src/server/scripts/Custom
COPY ./AzerothCore-Content/Modules/mod-moneyforkills/src/mod_moneyforkills.cpp /src/server/scripts/Custom
WORKDIR /src/build

RUN cmake /src -DSCRIPTS="dynamic" -DCMAKE_INSTALL_PREFIX=/output -DCONF_DIR=/output/etc
RUN make -j$(nproc) && make install

FROM environment as mapextractor

COPY --from=buildStep /output/bin/mapextractor /app/
COPY ./scripts/mapextractor.sh /app/

RUN chmod +x /app/mapextractor.sh

ENV WOW_DIR /wow
ENV OUTPUT_DIR /output

VOLUME /wow
WORKDIR /wow

ENTRYPOINT ["/app/mapextractor.sh"]

FROM environment as vmap4extractor

COPY --from=buildStep /output/bin/vmap4extractor /app/
COPY --from=buildStep /output/bin/vmap4assembler /app/
COPY ./scripts/vmap4extractor.sh /app/

RUN chmod +x /app/vmap4extractor.sh

WORKDIR /wow

ENV WOW_DIR /wow
ENV OUTPUT_DIR /output

VOLUME /wow
WORKDIR /wow

ENTRYPOINT ["/app/vmap4extractor.sh"]

FROM environment as mmaps_generator

COPY --from=buildStep /output/bin/mmaps_generator /app/
COPY ./scripts/mmaps_generator.sh /app/

RUN chmod +x /app/mmaps_generator.sh

WORKDIR /wow

ENV WOW_DIR /wow
ENV OUTPUT_DIR /output

VOLUME /wow
WORKDIR /wow

ENTRYPOINT ["/app/mmaps_generator.sh"]
