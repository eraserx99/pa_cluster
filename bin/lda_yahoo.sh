#!/bin/bash

#num_topics=500
num_iter=200
max_df=0.5
min_df=0.001
filt=all

# NO NEED TO EDIT BELOW HERE

## FUNCTIONS

function process_args {
	TMP=`getopt --name=$0 -a --longoptions=runId:,numTopics:,numIter:,maxDf:,minDf:,filter: -o r:,t:,x:,m:,n:,f:,h -- $@`
	eval set -- $TMP

	until [ $1 == -- ]; do
		case $1 in
			-r|--runId)
				run_id=$2 # option param is in position 2
				shift;; # remove the option's param
			-t|--numTopics)
				num_topics=$2
				shift;;
			-x|--numIter)
				num_iter=$2
				shift;;
			-m|--maxDf)
				max_df=$2
				shift;;
			-n|--minDf)
				min_df=$2
				shift;;
			-f|--filter)
				filt=$2
				shift;;
			-h)
				usage
				exit 1;;
		esac
		shift # move the arg list to the next option or '--'
	done
	shift # remove the '--', now $1 positioned at first argument if any

	if [[ -z $run_id ]] || [[ -z $num_topics ]]; then
		echo 'ERROR: Invalid args'
		usage
		exit 1
	fi
}

function usage {
cat << EOF
usage: $0 options

This script runs the Yahoo! LDA Test

REQUIRED OPTIONS:
	-r, --runId <arg>
		Id of the run
	-t, --numTopics <arg>
		Number of topics to assign

ADDITIONAL OPTIONS:
	-h      
		Show this message
	-f, --filter [all|cpr]
		Filter on data set
	-x, --numIter <arg>
		Number of iterations to run
	-m, --maxDf <arg>
		Maximum term document frequency
	-n, --minDf <arg>
		Minumum term document frequency
		
EOF
}

function setup {
	dir=/home/login/Projects/script/pa_cluster
	bin=/home/login/Yahoo_LDA
	utils_bin=/home/login/yahoo_lda_utils/bin
	out_dir=/data/pa_analysis_results/${run_id}-${filt}-${num_topics}t
	logfile=$dir/log/lda_yahoo.log
	input_docs_dir=/data/pa_analysis_docs
	task=1
	#export MAHOUT_LOCAL=true
}

function run {
	trap 'true' SIGHUP 		# ignore SIGHUP
	trap 'kill $(jobs -p)' EXIT 	# kill children if terminated

	do_cluster
}

function print_params {
	echo "PWD = $dir"
	echo "RUN_ID = $run_id"
	echo "NUM_TOPICS = $num_topics"
	echo "NUM_ITER = $num_iter"
	echo "MAX_DF = $max_df"
	echo "MIN_DF = $min_df"
	echo "FILTER = $filt"
}

function do_cluster {
	# prepare libraries
	cd $bin
	source $bin/setLibVars.sh

	# run scripts
	cd $dir
	print_params

	echo ">> BUILD INPUT FILE"

	if [ "$task" -le "1" ]; then
		rm -rf $out_dir
		bundle exec $dir/bin/build_yahoo_lda_input.rb $input_docs_dir $out_dir/input_file $filt
	fi

	echo ">> REMOVE MOST LEAST FREQ"

	if [ "$task" -le "2" ]; then
		cd $out_dir
		$utils_bin/chop_most_least_freq --input $out_dir/input_file --lower $min_df --upper $max_df > $out_dir/input_file.chopped
	fi

	echo ">> FORMAT"

	if [ "$task" -le "3" ]; then
		cd $out_dir
		cat $out_dir/input_file.chopped | $bin/formatter
		cd $dir
	fi

	echo ">> LEARN TOPICS"
	if [ "$task" -le "4" ]; then
		cd $out_dir
		$bin/learntopics --topics=$num_topics --iter=$num_iter
		cd $dir
	fi

	echo ">> COPY LOGS"
	cp $logfile $out_dir

}

process_args $@
setup
echo "Running script in background..."
echo "Writing log to $logfile"
run &> $logfile < /dev/null & disown
