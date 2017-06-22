all:
	make test AF=4  SIZE=100
	make test AF=7  SIZE=100
	make test AF=10  SIZE=100
	make test AF=20  SIZE=100

	make test AF=4  SIZE=1000
	make test AF=7  SIZE=1000
	make test AF=10  SIZE=1000
	make test AF=20  SIZE=1000

	make test AF=7  SIZE=10000
	make test AF=4  SIZE=10000
	make test AF=10  SIZE=10000
	make test AF=20  SIZE=10000

test:
	rm -rf r$(AF)s$(SIZE)M
	mkdir r$(AF)s$(SIZE)M
	(cd r$(AF)s$(SIZE)M && sudo ../run.sh $(SIZE) $(AF))
	chown fwu:fwu r$(AF)s$(SIZE)M
	cat */p99.log  | sort -k3,3d -k1,1g -k2,2g > p99_total.log

