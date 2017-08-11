all:
#	make test AF=4  SIZE=100
#	make test AF=7  SIZE=100
#	make test AF=10  SIZE=100
#	make test AF=20  SIZE=100

	make test AF=4  SIZE=1000
#	make test AF=7  SIZE=1000
	make test AF=10  SIZE=1000
#	make test AF=20  SIZE=1000

	make test AF=4  SIZE=10000
#	make test AF=7  SIZE=10000
	make test AF=10  SIZE=10000
#	make test AF=20  SIZE=10000

plot:
	./batch_p99.sh
	./split_p99.sh

test:
	sudo rm -rf r$(AF)s$(SIZE)M
	mkdir r$(AF)s$(SIZE)M
	(cd r$(AF)s$(SIZE)M && sudo ../run.sh $(SIZE) $(AF))
	sudo chown -R fwu:fwu r$(AF)s$(SIZE)M


other: 
	make test AF=20  SIZE=100
	make test AF=20  SIZE=1000
	make test AF=20  SIZE=10000

dummy:
	make test AF=10  SIZE=100

big:
	make test AF=4  SIZE=100000
	make test AF=10  SIZE=100000

big2:
	make test AF=4  SIZE=200000
	make test AF=10  SIZE=200000

small:
	make test AF=4  SIZE=1000
	make test AF=10  SIZE=1000


middle:
	make test AF=4  SIZE=10000
	make test AF=10  SIZE=10000
