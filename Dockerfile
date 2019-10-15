FROM rocker/shiny:latest

# Installing packages needed for check traffic on the container and kill if none

RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup && \
    echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache && \
    apt-get -qq update && apt-get install --no-install-recommends -y libgdal-dev libproj-dev net-tools procps libcurl4-openssl-dev libxml2-dev libssl-dev openjdk-8-jdk libgeos-dev texlive-xetex  texlive-fonts-recommended texlive-latex-recommended lmodern && \
    # Installing R package dedicated to the shniy app
    R CMD javareconf && \
    Rscript -e "install.packages('wallace')" && \
    # Bash script to check traffic
    mkdir /srv/shiny-server/sample-apps/SIG


RUN apt-get install -y git-all
RUN git clone -b v1.0.5 https://github.com/wallaceEcoMod/wallace.git &&\
    mv /wallace/inst /srv/shiny-server/sample-apps/SIG/wallace


# Add maxent module
RUN wget -O /usr/local/lib/R/site-library/dismo/java/maxent.jar https://github.com/mrmaxent/Maxent/blob/master/ArchivedReleases/3.3.3e/maxent.jar?raw=true

RUN apt-get install -y r-cran-rjava
RUN Rscript -e "install.packages('rJava')"
RUN mkdir /import

# Adapt download function to export to history Galaxy
COPY ./global.r /srv/shiny-server/sample-apps/SIG/wallace/shiny/
COPY ./shiny-server.conf /etc/shiny-server/shiny-server.conf

COPY ./ui.R /srv/shiny-server/sample-apps/SIG/wallace/shiny/ui.R
COPY ./server.R /srv/shiny-server/sample-apps/SIG/wallace/shiny/server.R

# Component 1
COPY ./Rmd/gtext_comp1_galaxyOccs.Rmd /srv/shiny-server/sample-apps/SIG/wallace/shiny/Rmd/gtext_comp1_galaxyOccs.Rmd
COPY ./modules/mod_c1_galaxyOccs.R /srv/shiny-server/sample-apps/SIG/wallace/shiny/modules/mod_c1_galaxyOccs.R

# Component 3
COPY ./Rmd/gtext_comp3_galaxyEnvs.Rmd /srv/shiny-server/sample-apps/SIG/wallace/shiny/Rmd/gtext_comp3_galaxyEnvs.Rmd
COPY ./modules/mod_c3_galaxyEnvs.R /srv/shiny-server/sample-apps/SIG/wallace/shiny/modules/mod_c3_galaxyEnvs.R
# Component 4

COPY ./modules/mod_c4_galaxyBgExtend.R /srv/shiny-server/sample-apps/SIG/wallace/shiny/modules/mod_c4_galaxyBgExtend.R
COPY ./Rmd/gtext_comp4_galaxyBg.Rmd /srv/shiny-server/sample-apps/SIG/wallace/shiny/Rmd/gtext_comp4_galaxyBg.Rmd

# Component 7
COPY ./modules/mod_c7_bcPlots.R /srv/shiny-server/sample-apps/SIG/wallace/shiny/modules/mod_c7_bcPlots.R
COPY ./modules/mod_c7_mxEvalPlots.R /srv/shiny-server/sample-apps/SIG/wallace/shiny/modules/mod_c7_mxEvalPlots.R
COPY ./modules/mod_c7_resPlots.R /srv/shiny-server/sample-apps/SIG/wallace/shiny/modules/mod_c7_resPlots.R

# Bash script to launch all processes needed
COPY shiny-server.sh /usr/bin/shiny-server.sh
# Python script to export data to history Galaxy
COPY ./export.py /opt/python/galaxy-export/export.py


# TEMP python import, dirty for the moment
COPY ./__init__.py /usr/local/lib/python2.7/dist-packages/galaxy_ie_helpers/__init__.py
COPY ./import_list_history.py /import_list_history.py
COPY ./global.r /srv/shiny-server/sample-apps/SIG/wallace/shiny/
COPY ./import_csv_user.py /import_csv_user.py

RUN apt-get install -y vim
CMD ["/usr/bin/shiny-server.sh"]
