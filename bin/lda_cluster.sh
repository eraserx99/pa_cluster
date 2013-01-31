#!/bin/bash

name=lda_cluster
task=5
num_clust=200

# NO NEED TO EDIT BELOW HERE
dir=/home/login/Projects/script/pa_cluster
bin=/usr/local/mahout-distribution-0.7/bin
logfile=$dir/$name.log
#export MAHOUT_LOCAL=true

function run {
	trap 'true' SIGHUP 		# ignore SIGHUP
	trap 'kill $(jobs -p)' EXIT 	# kill children if terminated

	cd $dir
	echo "PWD = $dir"

	echo ">> SEQDIRECTORY"

	if [ "$task" -le "1" ]; then
	  hadoop dfs -rmr -skipTrash ./out/seqfiles
	  $bin/mahout seqdirectory \
		--input             file:///data/patents-proc-with-cls \
		--output            ./out/seqfiles \
		--charset           utf-8 \
		-ow
	fi

	wait

	echo ">> SEQ2PARSE"

	if [ "$task" -le "2" ]; then
	  hadoop dfs -rmr -skipTrash ./out/lda-vectors
	  $bin/mahout seq2sparse \
		--input             ./out/seqfiles    \
		--output            ./out/lda-vectors     \
		--maxDFPercent      75                       \
		--namedVector				\
		-wt tf					\
		-ow
	fi

	echo ">> ROWID"
	if [ "$task" -le "3" ]; then
	  hadoop dfs -rmr -skipTrash ./out/lda-vectors-idx
	  $bin/mahout rowid \
		--input             ./out/lda-vectors/tf-vectors    \
		--output            ./out/lda-vectors-idx
	fi

	wait

	echo ">> CVB"
	# TODO: find number of terms in dictionary file
	if [ "$task" -le "4" ]; then
	  hadoop dfs -rmr -skipTrash ./out/lda-cluster-$num_clust
	  hadoop dfs -rmr -skipTrash ./temp/topicModelState
	  $bin/mahout cvb \
		--input 	    ./out/lda-vectors-idx/matrix \
		--output 	    ./out/lda-cluster-$num_clust \
		-dict		    ./out/lda-vectors/dictionary.file-0 \
		-dt		    ./out/lda-cluster-$num_clust-topics \
		-x		    10 \
		-k                  $num_clust \
		-nt		    30000 \
		-ow	
	fi

	echo ">> COPYFILES"
	if [ "$task" -le "5" ]; then
		rm -rf ./out/lda-cluster-$num_clust-out
		#rm -rf ./out/dir-vectors
		mkdir ./out/lda-cluster-$num_clust-out
		#hadoop dfs -get out/dir-cluster-$num_clust ./out/dir-cluster-$num_clust
		#hadoop dfs -get out/dir-vectors ./out/dir-vectors
	fi

	echo ">> SEQDUMPER"
	#hadoop dfs -mkdir ./out/lda-cluster-$num_clust-out
	$bin/mahout vectordump \
		--input ./out/lda-cluster-$num_clust \
		--dictionary ./out/lda-vectors/dictionary.file-0 \
		--dictionaryType sequencefile \
		--vectorSize 30 > ./out/lda-cluster-$num_clust-out/topicsmap \
		-sort 1
}

echo "Running script in background..."
run &> $logfile < /dev/null & disown
