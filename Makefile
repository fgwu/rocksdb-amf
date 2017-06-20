all:
	make test  SIZE=100
#	make test  SIZE=1000
#	make test  SIZE=10000

test:
	rm -rf r$(LEVEL_RATIO)s$(SIZE)M
	mkdir r$(LEVEL_RATIO)s$(SIZE)M
	(cd r$(LEVEL_RATIO)s$(SIZE)M && sudo ../run.sh $(SIZE))


