AUTHOR=dockpack
NAME=tomcat
VERSION=7

.PHONY: all build bash run
all: build

build:
	(cd ansible && ansible-galaxy install --force -r requirements.yml)
	docker build -t $(AUTHOR)/$(NAME):$(VERSION) .

bash:
	docker run -ti $(AUTHOR)/$(NAME):$(VERSION) /bin/bash

run:
	docker run -d -p 8080:8080 $(AUTHOR)/$(NAME):$(VERSION)
