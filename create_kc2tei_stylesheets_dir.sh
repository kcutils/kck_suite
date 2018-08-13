#!/bin/sh

SCRIPT=$( readlink -f "$0" )
SCRIPT_PATH=$( dirname "$SCRIPT" )

KCTEI_ZIP="${SCRIPT_PATH}/../kc2tei/kc2tei/target/kc2tei.zip"
KCTEI_ARCHVE_CREATOR="${SCRIPT_PATH}/../kc2tei/kc2tei/create_final_archive.sh"

STYLESHEET_ZIP="${SCRIPT_PATH}/../kctei_stylesheets/kctei_stylesheets.zip"
STYLESHEET_ARCHIVE_CREATOR="${SCRIPT_PATH}/../kctei_stylesheets/create_final_archive.sh"

cd ${SCRIPT_PATH}

echo "Creating kc2tei structure ..."

rm -rf kc2tei/
OUT=$( $KCTEI_ARCHVE_CREATOR 2>&1 )
if [ $? -ne 0 ]; then
  echo "$OUT"
  exit 1
fi

OUT=$( cp -a "$KCTEI_ZIP" . 2>&1 )
if [ $? -ne 0 ]; then
  echo "Error while copying archive!"
  echo "$OUT"
  echo "Exitting ..."
  exit 1
fi

OUT=$( unzip kc2tei.zip 2>&1 )
if [ $? -ne 0 ]; then
  echo "Error while unzipping archive!"
  echo "$OUT"
  echo "Exitting ..."
  exit 1
fi

rm kc2tei.zip
rm -rf kc2tei/data/

echo "Creating kctei_stylesheets structure ..."

rm -rf kctei_stylesheets/

OUT=$( $STYLESHEET_ARCHIVE_CREATOR 2>&1 )
if [ $? -ne 0 ]; then
  echo "$OUT"
  exit 1
fi

OUT=$( cp -a "$STYLESHEET_ZIP" . 2>&1 )
if [ $? -ne 0 ]; then
  echo "Error while copying archive!"
  echo "$OUT"
  echo "Exitting ..."
  exit 1
fi

OUT=$( unzip kctei_stylesheets.zip 2>&1 )
if [ $? -ne 0 ]; then
  echo "Error while unzipping archive!"
  echo "$OUT"
  echo "Exitting ..."
  exit 1
fi

rm kctei_stylesheets.zip
rm -rf kctei_stylesheets/data/

