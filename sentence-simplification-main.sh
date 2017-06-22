#!/bin/bash

#Validate arguments
if [[ ! ("$#" == 2 ) ]]; then 
    echo 'Usage: ./sentence-simplification-main.sh <batch_keyword> <output_file_path>'
    exit 1
fi

SCRIPT_PATH=$(cd `dirname $0` && pwd)
#Define aquí la palabra clave del grupo de oraciones a simplificar.
BATCH_KEYWORD=$1
OUTPUT_INDEX_FILE_PATH=$2
cd $SCRIPT_PATH




#Remove input_file's file extension
BATCH_KEYWORD=${BATCH_KEYWORD::-4}


#ELIMINAR FORMATO DE ARTÍCULO CON "SANITIZADOR"
echo "Sanitizing text for $BATCH_KEYWORD batch..."
if [ -z "$(ls -A ./sanitized_sentences/)" ]; then
   echo "directory is clean."
else
   #echo "Not Empty"
   rm ./sanitized_sentences/*
fi
#rm ./sanitized_sentences/*
cd ./10pack_sentences
for i in $(\ls $BATCH_KEYWORD*)
do
	echo $i
	python2 $SCRIPT_PATH/regex.py $SCRIPT_PATH/10pack_sentences/$i $SCRIPT_PATH/sanitized_sentences/$i
done
cd $SCRIPT_PATH



#SEPARA EN ORACIONES INDIVIDUALES
echo "Splitting..."
echo "Sanitizing text for $BATCH_KEYWORD batch..."
if [ -z "$(ls -A ./split_sentences/)" ]; then
   echo "directory is clean."
else
   #echo "Not Empty"
   rm ./split_sentences/*
fi
#rm ./split_sentences/*
cd ./sanitized_sentences
for l in $(\ls $BATCH_KEYWORD*)
do
	echo $l
	python2 $SCRIPT_PATH/splitter.py $SCRIPT_PATH/sanitized_sentences/$l $SCRIPT_PATH/split_sentences/$l	
done
cd $SCRIPT_PATH



#ANALIZAR EN ISIMP
echo "Analysing in iSimp..."
if [ -z "$(ls -A ../iSimp_sentences/)" ]; then
   echo "directory is clean."
else
   #echo "Not Empty"
   rm ./iSimp_sentences/*
fi
#rm ./iSimp_sentences/*
cd ./split_sentences
for j in $(\ls $BATCH_KEYWORD*)
do
	echo $j
	$SCRIPT_PATH/isimp_v2/simplify.sh $SCRIPT_PATH/split_sentences/$j $SCRIPT_PATH/iSimp_sentences/$j	
done
cd $SCRIPT_PATH

#CREA INDICE DE ARCHIVOS SIMPLIFICADOS
#touch $SCRIPT_PATH/index.txt
>| $OUTPUT_INDEX_FILE_PATH

#ALIMENTAR A ALGORITMO 
echo "Analysing in Algorithm..."
cd ./iSimp_sentences
for k in $(\ls $BATCH_KEYWORD*)
do
	echo $k
	python2 $SCRIPT_PATH/simplifier.py $SCRIPT_PATH/iSimp_sentences/$k $SCRIPT_PATH/algorithm_sentences/$k $OUTPUT_INDEX_FILE_PATH
done
cd $SCRIPT_PATH
