#! /bin/bash

## The filtered vcf files are run through VEP in offline mode, to annotate the resulted variants

vep_exec=/opt/ensembl-tools-release-87/scripts/variant_effect_predictor/variant_effect_predictor.pl

function usage {
	echo "usage: [options] vc_vep.sh source_dir dest_dir"
	echo "Options:"
	echo '	-h, --help: show this help'
	echo '	-v, --vep:  vep executable'
}

while [ $# -gt 2 ]; do
  case $1 in 
	-h | --help	) usage
			  exit
			  ;;
	-v | --vep	) shift
			  vep_exec=$1
			  shift
			  ;;
	*		) echo "Unknown option $1"
			  usage
			  exit 1
  esac
done

if [ $# -lt 2 ]; then
	usage
	exit
fi

source_dir=${1%/}
dest_dir=${2%/}

if [ ! -d ${source_dir} ]; then
	echo "${source_dir} is a file"
	exit
fi

if [ -f $dest_dir ]; then
	echo "${dest_dir} is a file"
	exit 1
fi

mkdir -p $dest_dir
 
for f in ${source_dir}/*_filtered.vcf ; do
  sample=$(basename $f)
  sample=${sample%.vcf}
  (
	perl ${vep_exec} --input_file ${f} --output_file ${dest_dir}/${sample}.txt --everything --cache --dir_cache /seqdata/vep_cache/ --species homo_sapiens --offline
  ) &
done

wait
