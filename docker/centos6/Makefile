AUTHOR=dockpack
NAME=centos
VERSION=6

.PHONY: all build bash run
all: build

build:
	docker build -t $(AUTHOR)/$(NAME):$(VERSION) .

bash:
	docker run -ti -m 2g -p 2222:22 $(AUTHOR)/$(NAME):$(VERSION) /bin/bash

run:
	docker run -d -m 2g -p 2222:22 $(AUTHOR)/$(NAME):$(VERSION)
