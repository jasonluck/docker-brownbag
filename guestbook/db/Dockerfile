FROM openjdk:8

#Define ENV variables
ENV DB_HOST="app-db"
ENV DB_PORT="3306"
ENV DB_USER=""
ENV DB_PASSWORD=""
ENV DB_DATABASE=""
ENV CHANGELOG="/usr/src/db/changelog.yml"

#Install Liquibase
RUN mkdir /opt/liquibase
ADD https://github.com/liquibase/liquibase/releases/download/liquibase-parent-3.5.3/liquibase-3.5.3-bin.tar.gz /tmp/liquibase-3.5.3-bin.tar.gz
RUN tar -xzf /tmp/liquibase-3.5.3-bin.tar.gz -C /opt/liquibase; \
    chmod +x /opt/liquibase/liquibase; \
    rm /tmp/liquibase-3.5.3-bin.tar.gz;

#RUN curl -O https://github.com/liquibase/liquibase/releases/download/liquibase-parent-3.5.3/liquibase-3.5.3-bin.tar.gz \
#    tar -xf liquibase-3.5.3-bin.tar.gz

#Install the MySQL JDBC Driver
ADD https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.40.tar.gz /tmp/mysql-connector-java-5.1.40.tar.gz
RUN cd /tmp; \
    tar -xzf /tmp/mysql-connector-java-5.1.40.tar.gz; \
    mv /tmp/mysql-connector-java-5.1.40/mysql-connector-java-5.1.40-bin.jar /opt/liquibase/lib; \
    rm -rf /tmp/mysql-connector-java-5.1.40;

#Add our changelogs to the image
COPY changelogs /usr/src/db
COPY run-liquibase.sh /opt/run-liquibase.sh

#Define our entry points, Update is the default
ENTRYPOINT ["/opt/run-liquibase.sh"]
CMD ["update"]
