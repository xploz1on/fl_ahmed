FROM rocker/r-base:latest
LABEL maintainer="CytoTalk <info@cytotalk.com>"
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libsodium-dev \
    libssl-dev \
    libssh2-1-dev \
    && rm -rf /var/lib/apt/lists/*
RUN R -e "install.packages('shiny')"
RUN R -e "install.packages('tibble')"
RUN R -e "install.packages('shinydashboard')"
RUN R -e "install.packages('highcharter')"
RUN R -e "install.packages('DT')"
RUN R -e "install.packages('lubridate')"
RUN R -e "install.packages('tidyr')"
RUN R -e "install.packages('tychobratools')"
RUN R -e "install.packages('openxlsx')"
RUN R -e "install.packages('officer')"
RUN R -e "install.packages('flextable')"
RUN R -e "install.packages('ggrepel')"
RUN R -e "install.packages('dplyr')"
RUN R -e "install.packages('sodium')"
RUN R -e "install.packages('shinyauthr')"
RUN R -e "install.packages('hrbrthemes')"
RUN R -e "install.packages('plotly')"
RUN R -e "install.packages('shinydisconnect')"
RUN R -e "install.packages('shinymanager')"
RUN R -e "install.packages('RSQLite')"

RUN echo "local(options(shiny.port = 3838, shiny.host = '0.0.0.0'))" > /usr/lib/R/etc/Rprofile.site
RUN addgroup --system app \
    && adduser --system --ingroup app app
WORKDIR /home/app
COPY app .
RUN chown app:app -R /home/app
RUN chmod 777 -R /home/app/
USER app
EXPOSE 3838
CMD ["R", "-e", "shiny::runApp('/home/app')"]


