#! /bin/bash

## Realigns the sorted bam files from sort_and_index_rmdup.sh script, this script uses GATK tool

gatk=/opt/GenomeAnalysisTK.jar
java=/opt/java/JavaVirtualMachines/jdk1.8.0_102/bin/java

function usage {
	echo "usage: realign_GATK.sh [options] source_dir genome_file output_dir"
	echo "Options:"
	echo '	-h, --help:	Show this help'
	echo '	-g, --gatk:	gatk executable (defaults to gatk)'
	echo '	-j, --java:	path to Java executable'
}

while [ $# -gt 3 ]; do
	case $1 in
		-h | --help	) usage
				exit
				;;
		-g | --gatk	) shift
				gatk=$1
				shift
				;;
		-j | --java	) shift
				java=$1
				shift
				;;
		*		) echo "Unknown option $1"
				usage
				exit 1
	esac
done

if [ $# -lt 3 ]; then
	usage
	exit
fi

source_dir=${1%/}
genome_file=$2
dest_dir=${3%/}

if [ ! -d ${source_dir} ]; then
	echo "${source_dir} is a file"
	exit
fi

if [ -f $dest_dir ]; then
	echo "${dest_dir} is a file"
	exit
fi

mkdir -p $dest_dir/intervals

for f in ${source_dir}/*.bam; do
    filename=$(basename $f)
    (
	${java} -jar ${gatk} -T RealignerTargetCreator -R ${genome_file} -I ${f} -o ${dest_dir}/intervals/${filename}.intervals 
	${java} -jar ${gatk} -T IndelRealigner -R ${genome_file} -I ${f} -targetIntervals ${dest_dir}/intervals/${filename}.intervals -o ${dest_dir}/${filename/.bam/.bam}
    ) &
done

wait
	
