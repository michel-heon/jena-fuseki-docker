FROM eclipse-temurin:17-jdk

# Define versions
ARG JENA_VERSION=5.2.0

# Define dataset name
ENV FUSEKI_DATASET=dataset

# Install necessary tools and download Fuseki
RUN apt-get update && \
    apt-get install -y wget && \
    wget https://dlcdn.apache.org/jena/binaries/apache-jena-fuseki-${JENA_VERSION}.tar.gz && \
    tar -xzvf apache-jena-fuseki-${JENA_VERSION}.tar.gz -C /opt && \
    rm apache-jena-fuseki-${JENA_VERSION}.tar.gz && \
    apt-get remove -y wget && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV FUSEKI_HOME=/opt/apache-jena-fuseki-${JENA_VERSION}
ENV FUSEKI_BASE=/opt/run
ENV JENA_HOME=$FUSEKI_HOME
ENV PATH="${JENA_HOME}/bin:${PATH}"

# Set working directory
WORKDIR $FUSEKI_HOME
RUN ls -al $FUSEKI_HOME

# Copy custom configuration file into the image
COPY config.ttl $FUSEKI_BASE/config.ttl
COPY shiro.ini $FUSEKI_BASE/shiro.ini
COPY log42j.properties $FUSEKI_HOME/log42j.properties

# Expose Fuseki port
EXPOSE 3030

# Entry point script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
