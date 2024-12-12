build:
	mkdir -p bin && apptainer build bin/smcpp_v1.15.4 docker://terhorst/smcpp:version-1.15.4
run: 
	module load Nextflow/24.10.2
	nextflow run main.nf