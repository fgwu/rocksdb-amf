all:
	make test LEVEL_RATIO=04 SIZE=100
	make test LEVEL_RATIO=04 SIZE=1000
	make test LEVEL_RATIO=04 SIZE=10000

test:
	rm -rf r$(LEVEL_RATIO)s$(SIZE)M
	mkdir r$(LEVEL_RATIO)s$(SIZE)M
	(cd r$(LEVEL_RATIO)s$(SIZE)M && ../run.sh $(SIZE))


