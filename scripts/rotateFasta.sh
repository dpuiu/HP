#!/usr/bin/env bash

####################################
#1: sequence id (ex: chrM)
#2: sequence FASTA file prefix (ex: path/chrM)
#3: extensio length (ex:300)
#4: output files prefix
####################################

export N=$1
export S=$2
export E=$3
SE=$4

test -s $S.fa
test -s $S.fa.fai

cat $S.fa.fai | perl -ane 'print "$F[0]\t",$F[1]-$ENV{E},"\t$F[1]\n$F[0]\t0\t",$F[1]-$ENV{E},"\n";' | \
    bedtools getfasta -fi $S.fa -bed - -fo /dev/stdout  | grep -v ">" |  perl -ane 'BEGIN { print ">$ENV{N}\n" }  chomp; print ; END {print "\n"}' > $SE.fa

samtools faidx $SE.fa

rm -f $SE.dict
java -jar $HP_JDIR/gatk.jar CreateSequenceDictionary --REFERENCE $SE.fa --OUTPUT $SE.dict
