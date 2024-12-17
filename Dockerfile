FROM eclipse-temurin:17-jdk

# Define versions
ARG JENA_VERSION=5.2.0

# Install necessary tools and download Jena and Fuseki
RUN apt-get update && \
    apt-get install -y wget && \
    wget https://dlcdn.apache.org/jena/binaries/apache-jena-${JENA_VERSION}.tar.gz && \
    wget https://dlcdn.apache.org/jena/binaries/apache-jena-fuseki-${JENA_VERSION}.tar.gz && \
    tar -xzf apache-jena-${JENA_VERSION}.tar.gz -C /opt && \
    tar -xzf apache-jena-fuseki-${JENA_VERSION}.tar.gz -C /opt && \
    rm apache-jena-${JENA_VERSION}.tar.gz apache-jena-fuseki-${JENA_VERSION}.tar.gz && \
    apt-get remove -y wget && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV JENA_HOME=/opt/apache-jena-${JENA_VERSION}
ENV FUSEKI_HOME=/opt/apache-jena-fuseki-${JENA_VERSION}
ENV PATH="${JENA_HOME}/bin:${PATH}"

# Set working directory
WORKDIR $FUSEKI_HOME

# Copy custom configuration file into the image
COPY config-tdb2.ttl /fuseki/config-tdb2.ttl

# Expose Fuseki port
EXPOSE 3030

# Entry point script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
