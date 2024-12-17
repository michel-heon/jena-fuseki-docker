# Apache Jena Fuseki Docker Setup

This project provides a Dockerized environment for Apache Jena Fuseki, a SPARQL 1.1 server with a web interface, backed by the Apache Jena TDB RDF triple store.

## Prerequisites

- [Docker](https://www.docker.com/get-started) installed on your system.
- [Docker Compose](https://docs.docker.com/compose/install/) installed.
- `make` utility installed. On Ubuntu, you can install it using the following command:

   ```bash
   sudo apt update
   sudo apt install make
   ```

- This setup has been tested on **Ubuntu 22.04**. It may work on other operating systems, but compatibility is not guaranteed.

## Project Structure

- `Dockerfile`: Defines the Docker image for Apache Jena Fuseki.
- `Makefile`: Contains commands to build, run, load data, query, and manage the Docker container.
- `data/paul-family.ttl`: Sample Turtle (TTL) file containing RDF data.
- `query.rq`: SPARQL query file to interact with the dataset.
- `config-tdb2.ttl`: Configuration file for setting up a TDB2-backed dataset in Fuseki.

## First Run

To quickly set up and test Apache Jena Fuseki with a TDB2-backed dataset, execute the following commands:

```bash
make build      # Build the Docker image
make run-tdb2   # Start Fuseki with a TDB2 dataset
make load       # Load sample RDF data into the dataset
make query      # Execute a SPARQL query and display the results
```

Once these commands are completed, you can access:

- The Fuseki Admin Interface: [http://localhost:3030/](http://localhost:3030/)
- SPARQL Query Results: Displayed directly in the terminal.

---

## Setup and Usage

1. **Build the Docker Image:**

   ```bash
   make build
   ```

   This command builds the Docker image for Apache Jena Fuseki using the provided `Dockerfile`.

2. **Run Fuseki with an In-Memory Dataset:**

   ```bash
   make run
   ```

   Starts the Fuseki server with an in-memory dataset accessible at [http://localhost:3030/](http://localhost:3030/).

3. **Run Fuseki with a TDB2 Dataset:**

   ```bash
   make run-tdb2
   ```

   Starts the Fuseki server with a TDB2-backed dataset using the configuration specified in `config-tdb2.ttl`.

4. **Load Data into Fuseki:**

   ```bash
   make load
   ```

   Loads RDF data from `data/paul-family.ttl` into the dataset. Ensure the server is running before executing this command.

5. **Execute a SPARQL Query:**

   ```bash
   make query
   ```

   Sends the SPARQL query defined in `query.rq` to the Fuseki server and displays the results.

6. **Stop the Running Fuseki Container:**

   ```bash
   make stop
   ```

   Stops the Fuseki Docker container if it's running.

7. **Clean Up Docker Resources:**

   ```bash
   make clean
   ```

   Stops the running container and removes the Docker image to free up system resources.

8. **Display Available Makefile Targets:**

   ```bash
   make help
   ```

   Displays a list of available `Makefile` targets along with their descriptions, facilitating easier navigation and usage of the `Makefile`.

## Configuration

- **`config-tdb2.ttl`:** This file configures the TDB2 dataset for Fuseki. Ensure it's correctly set up to define your dataset and endpoints.

- **`query.rq`:** Contains the SPARQL query to be executed against the dataset. Modify this file to change the query as needed.

## Notes

- **Data Persistence:** When using a TDB2-backed dataset, consider mounting a Docker volume to `/fuseki/databases` to persist data across container restarts.

- **Port Configuration:** The default port is `3030`. If this port is in use or you prefer a different port, modify the `-p` flag in the `Makefile` accordingly.

- **Admin Interface:** Access the Fuseki admin interface at [http://localhost:3030/](http://localhost:3030/).

## References

- [Apache Jena Fuseki Documentation](https://jena.apache.org/documentation/fuseki2/)
- [Docker Official Documentation](https://docs.docker.com/)

---

## Disclaimer

This project is provided "as is" without any warranties, express or implied. The author assumes no responsibility for any damages or issues that may arise from the use of this software. Users are encouraged to test the software in their environment before relying on it for production purposes.

---

*This project is maintained by [Michel Héon PhD](https://github.com/michel-heon).*
```