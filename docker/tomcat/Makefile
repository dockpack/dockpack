AUTHOR=dockpack
NAME=tomcat
VERSION=7

.PHONY: all build bash run
all: build

build:
	(cd ansible && ansible-galaxy install --force -r requirements.yml)
	docker build -t $(AUTHOR)/$(NAME):$(VERSION) .

bash:
	docker exec -ti tomcat /bin/bash

run:
	docker run --name tomcat -d -p 8080:8080 $(AUTHOR)/$(NAME):$(VERSION)
