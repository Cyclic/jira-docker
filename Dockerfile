FROM debian:stretch

RUN useradd -u 1100 postgres && useradd -u 1099 dummyuser

RUN apt-get -y update && \
apt-get -y install wget nano git postgresql && rm -rf /var/lib/apt/lists/*

RUN  mkdir -p /home/dbbackup && cp -n /var/lib/postgresql/9.6/main/* /home/dbbackup/

COPY check.gpr /check.gpr
COPY ./installjira /installjira
RUN  cp -n ./dbconfig.xml /var/atlassian/jira-home/dbconfig.xml

RUN cd / && wget https://product-downloads.atlassian.com/software/jira/downloads/atlassian-jira-software-7.11.1-x64.bin \
&& sha256sum -c check.gpr \
&& chmod a+x atlassian-jira-software-7.11.1-x64.bin \
&& cd / && ./atlassian-jira-software-7.11.1-x64.bin < ./installjira \
&& rm /atlassian-jira-software-7.11.1-x64.bin \
&& mkdir -p /home/jira-app-backup/ && cp -n /var/atlassian/jira-app/* /home/jira-app-backup/ \
&& mkdir -p /home/jira-home-backup/ && cp -n /var/atlassian/jira-home/* /home/jira-home-backup/

VOLUME /var/lib/postgresql/9.6/main /var/atlassian/jira-app /var/atlassian/jira-home

EXPOSE 8080

COPY ./entrypoint.sh /entrypoint.sh
COPY ./createdb.sql /createdb.sql

ENTRYPOINT [ "/entrypoint.sh" ]
