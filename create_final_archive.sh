#!/usr/bin/env sh

SCRIPT=$( readlink -f "$0" )
SCRIPT_PATH=$( dirname "$SCRIPT" )

cd ${SCRIPT_PATH}
./create_kc2tei_stylesheets_dir.sh

if [ $? -ne 0 ]; then
  echo "Error while creating directory structure!"
  echo "Exitting ..."
  exit 1
fi

echo "Creating archive ..."
rm -f ./kck_suite.zip
cd ..

OUT=$( zip -r kck_suite/kck_suite.zip kck_suite/LICENSE kck_suite/README* kck_suite/data kck_suite/corpus_files.txt kck_suite/convert_corpus.sh kck_suite/run_conversion_chain.sh kck_suite/kc2tei/ kck_suite/kctei_stylesheets/ -x \*.git* -x\*saxon9he.jar 2>&1 )
if [ $? -ne 0 ]; then
  echo "Error while creating archive!"
  echo "$OUT"
  echo "Exitting ..."
  exit 1
fi

