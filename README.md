

## Configuration

- **Docker Image**: `jena-fuseki:5.2.0`
- **Container Name**: `jena-fuseki`
- **Data File**: `./data/paul-family.ttl`
- **SPARQL Query File**: `./query.rq`
- **Fuseki Dataset**: `dataset`
- **Fuseki Update URL**: `http://localhost:3030/dataset/data?default`
- **Fuseki Query URL**: `http://localhost:3030/dataset/sparql`

## Makefile Targets

- `build`: Build the Docker image.
- `run`: Run Fuseki with an in-memory dataset.
- `run-tdb2`: Run Fuseki with a TDB2 dataset using the provided configuration.
- `load`: Load data into the Fuseki dataset.
- `query`: Send a SPARQL query to the Fuseki dataset.
- `wait-for-fuseki`: Wait for Fuseki to be ready.
- `stop`: Stop the running Fuseki container.
- `clean`: Clean up Docker resources.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
