.PHONY: all
all: 
	$(MAKE) -C containers/justsotech-com


.PHONY: push
push: 
	$(MAKE) -C containers/justsotech-com push


