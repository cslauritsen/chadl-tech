MAJOR?=0
MINOR?=1
PATCH := $(shell date '+%s')

VERSION=$(MAJOR).$(MINOR)
VERSIONL=$(MAJOR).$(MINOR).$(PATCH)

REG ?= docker.io
REPO ?= cslauritsen
IMG ?= $(shell basename `pwd`)

.PHONY: all 
all: clean push

.PHONY: clean
clean:
	rm -fr public
	
.PHONY: image
image:
	docker build -t $(REPO)/$(IMG):$(VERSIONL) .
	docker tag $(REPO)/$(IMG):$(VERSIONL) $(REG)/$(REPO)/$(IMG):$(VERSIONL)
	docker tag $(REPO)/$(IMG):$(VERSIONL) $(REG)/$(REPO)/$(IMG):$(VERSION)
	docker tag $(REPO)/$(IMG):$(VERSIONL) $(REG)/$(REPO)/$(IMG):latest

.PHONY: push
push: image
	docker push $(REG)/$(REPO)/$(IMG):$(VERSION)
	docker push $(REG)/$(REPO)/$(IMG):$(VERSIONL)
	docker push $(REG)/$(REPO)/$(IMG):latest
