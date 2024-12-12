build:
	mkdir external bin
	cd external && git clone https://github.com/esrud/GONE2
	cd GONE2 && make MAXLOCI=3000000 MAXIND=100
	cp GONE2 ../../bin/
run: 
	module load Nextflow/24.10.2
	nextflow run main.nf