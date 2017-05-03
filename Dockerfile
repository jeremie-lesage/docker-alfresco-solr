FROM tomcat:7.0.77-jre8
MAINTAINER Jeremie Lesage <jeremie.lesage@gmail.com>

ENV NEXUS=https://artifacts.alfresco.com/nexus/content/groups/public

WORKDIR /usr/local/tomcat/

ARG ALF_VERSION

## SOLR.WAR
RUN set -x && \
    curl --silent --location \
      ${NEXUS}/org/alfresco/alfresco-solr4/${ALF_VERSION}/alfresco-solr4-${ALF_VERSION}.war \
      -o alfresco-solr4-${ALF_VERSION}.war && \
    unzip -q alfresco-solr4-${ALF_VERSION}.war -d webapps/solr4 && \
    rm alfresco-solr4-${ALF_VERSION}.war

COPY assets/web.xml webapps/solr4/WEB-INF/web.xml

WORKDIR /opt/solr/

## SOLR CONF
RUN set -x && \
    curl --silent --location \
      ${NEXUS}/org/alfresco/alfresco-solr4/${ALF_VERSION}/alfresco-solr4-${ALF_VERSION}-config.zip \
      -o alfresco-solr4-${ALF_VERSION}-config.zip && \
    unzip -q alfresco-solr4-${ALF_VERSION}-config.zip -d conf && \
    rm alfresco-solr4-${ALF_VERSION}-config.zip

WORKDIR /opt/solr/conf/

RUN set -x \
      && mkdir /opt/solr_data/ \
      && sed -i 's|^data.dir.root=.*$|data.dir.root=/opt/solr|' workspace-SpacesStore/conf/solrcore.properties \
      && sed -i 's/^alfresco.host=.*$/alfresco.host=alfresco/' workspace-SpacesStore/conf/solrcore.properties \
      && sed -i 's/^alfresco.secureComms=.*$/alfresco.secureComms=none/' workspace-SpacesStore/conf/solrcore.properties \
      && sed -i 's|^data.dir.root=.*$|data.dir.root=/opt/solr|' archive-SpacesStore/conf/solrcore.properties \
      && sed -i 's/^alfresco.host=.*$/alfresco.host=alfresco/' archive-SpacesStore/conf/solrcore.properties \
      && sed -i 's/^alfresco.secureComms=.*$/alfresco.secureComms=none/' archive-SpacesStore/conf/solrcore.properties \
      && sed -i 's|${data.dir.root}|/opt/solr_data/|' workspace-SpacesStore/conf/solrconfig.xml \
      && sed -i 's|${data.dir.root}|/opt/solr_data/|' archive-SpacesStore/conf/solrconfig.xml \
      && rm -rf /usr/share/doc \
                webapps/docs \
                webapps/examples \
                webapps/manager \
                webapps/host-manager


VOLUME "/opt/solr_data/"
WORKDIR /root
