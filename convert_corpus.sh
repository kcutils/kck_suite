#!/usr/bin/env sh

SCRIPT=$( readlink -f "$0" )
SCRIPT_PATH=$( dirname "$SCRIPT" )

CONVERSION_SCRIPT="${SCRIPT_PATH}/run_conversion_chain.sh"

CORPUS_FILES_LIST_DEFAULT="${SCRIPT_PATH}/corpus_files.txt"

CORPUS_ROOT_PATH_DEFAULT="${SCRIPT_PATH}/KielCorpus/"

usage () {

}

clean_exit () {
  wait
  echo
  echo "Stopping ..."
  date
  exit
}
trap clean_exit 2

while [ $# -gt 0 ]; do
  case $1 in
    -c)
      CONVERSION_SCRIPT="$2"
      shift
    ;;
    -l)
      CORPUS_FILES_LIST="$2"
      shift
    ;;
    -r)
      CORPUS_ROOT_PATH="$2"
      shift
    ;;
    -h|--help)
      usage
      exit
    ;;
    *)
    ;;
  esac
  shift
done

if [ "$CONVERSION_SCRIPT" = "" ]; then
  CONVERSION_SCRIPT=$CONVERSION_SCRIPT_DEFAULT
fi

if [ ! -e "$CONVERSION_SCRIPT" ]; then
  echo "ERROR: Unable to find conversion script ${CONVERSION_SCRIPT}!"
  echo "Exitting ..."
  exit 1
fi

if [ "$CORPUS_FILES_LIST" = "" ]; then
  CORPUS_FILES_LIST=$CORPUS_FILES_LIST_DEFAULT
fi

if [ ! -e "$CORPUS_FILES_LIST" ]; then
  echo "ERROR: Unable to find list of corpus files ${CORPUS_FILES_LIST}!"
  echo "Exitting ..."
  exit 1
fi

if [ "$CORPUS_ROOT_PATH" = "" ]; then
  CORPUS_ROOT_PATH=$CORPUS_ROOT_PATH_DEFAULT
fi

if [ ! -d "$CORPUS_ROOT_PATH" ]; then
  echo "ERROR: Unable to find corpus root path ${CORPUS_ROOT_PATH}!"
  echo "Exitting ..."
  exit 1
fi

FILES=$( cat "$CORPUS_FILES_LIST" )

# we want to see some progress during processing files
FILE_AMOUNT=$( echo "$FILES" | wc -l | awk '{print $1}' )

MSG_ALL_NR_FILES=50

COUNTER=0
ALL_COUNTER=0

date
echo "Processing $FILE_AMOUNT Kiel Corpus files ..."
echo -n "... "

for F in $FILES; do

  # progress message
  if [ $COUNTER -eq $MSG_ALL_NR_FILES ]; then
    ALL_COUNTER=$(( $ALL_COUNTER + $MSG_ALL_NR_FILES ))
    echo -n " $ALL_COUNTER ..."
    COUNTER=0
  fi

  FILE="${CORPUS_ROOT_PATH}/${F}"
  OUT=$( $CONVERSION_SCRIPT "$FILE" 2>&1 )
  if [ $? -ne 0 ]; then
    echo "ERROR: unable to convert ${FILE}!"
    echo "$OUT"
  fi

  COUNTER=$(( COUNTER + 1 ))

done

clean_exit
