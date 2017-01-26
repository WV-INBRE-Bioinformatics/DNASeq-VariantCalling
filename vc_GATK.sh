#! /bin/bash

## Mutect2 from GATK is used to compare Normal Vs Tumor samples, outputs in vcf file format

gatk_exec=/opt/GenomeAnalysisTK-3.7/GenomeAnalysisTK.jar
java=/opt/java/JavaVirtualMachines/jdk1.8.0_102/bin/java

function usage {
	echo "usage: [options] vc_gatk_compare.sh source_dir genome_file dest_dir"
	echo "Options:"
	echo '	-h, --help: show this help'
	echo '	-g, --gatk: gatk executable'
	echo '	-j, --java: path to Java executable'
}

while [ $# -gt 3 ]; do
  case $1 in 
	-h | --help	) usage
			  exit
			  ;;
	-g | --gatk	) shift
			  gatk_exec=$1
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
	exit 1
fi

mkdir -p $dest_dir

for f in ${source_dir}/*.bam; do
  name=${f%%[-]*}
  bName=$(basename $name)
  filename_N=${name}-Normal
  filename_O=${name}-Original
  output=${dest_dir}/${bName}-N_vs_O.vcf
 (
	java -jar ${gatk_exec} -T MuTect2 -R ${genome_file} -I:tumor ${filename_O}.bam -I:normal ${filename_N}.bam -o ${output}
  ) &
#  echo "name: ${name}"
#  echo "filename_O: ${filename_O}"
#  echo "filename_P: ${filename_P}"
#  echo "output: ${output}"
done

wait
