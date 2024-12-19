# Variables
VERSION=5.2.0
FUSEKI_URL=https://dlcdn.apache.org/jena/binaries/apache-jena-fuseki-$(VERSION).tar.gz
INSTALL_DIR=./fuseki
FUSEKI_DIR=$(realpath $(INSTALL_DIR)/apache-jena-fuseki-$(VERSION))
PID_FILE=$(FUSEKI_DIR)/fuseki.pid

# Règles
all: install

install: $(FUSEKI_DIR)

$(FUSEKI_DIR):
	mkdir -p $(INSTALL_DIR)
	curl -L $(FUSEKI_URL) | tar -xz -C $(INSTALL_DIR)
# --config=/home/ubuntu/UQAM_GPT/00-GIT/jena-docker/config-tdb2.ttl
start: $(FUSEKI_DIR)
	@if [ -f $(PID_FILE) ]; then \
		echo "Fuseki est déjà en cours d'exécution."; \
	else \
		nohup $(FUSEKI_DIR)/fuseki-server  > $(FUSEKI_DIR)/fuseki.log 2>&1 & \
		echo $$! > $(PID_FILE); \
		echo "Fuseki démarré."; \
		$(MAKE) log; \
	fi

stop:
	@if [ -f $(PID_FILE) ]; then \
		kill $$(cat $(PID_FILE)) && rm $(PID_FILE); \
		echo "Fuseki arrêté."; \
	else \
		echo "Fuseki n'est pas en cours d'exécution."; \
	fi

log:
	tail -f $(FUSEKI_DIR)/fuseki.log

clean:
	rm -rf $(INSTALL_DIR)
