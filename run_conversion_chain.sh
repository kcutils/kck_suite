#!/usr/bin/env sh

SCRIPT=$( readlink -f "$0" )
SCRIPT_PATH=$( dirname "$SCRIPT" )

KCTEI_CONVERTER_DEFAULT="${SCRIPT_PATH}/kc2tei/kc2tei.sh"
KCTEI_XML_CONVERTER_DEFAULT="${SCRIPT_PATH}/kctei_stylesheets/convert.sh"

usage () {
cat << END

  $0 [-h|--help] [-t|--praat] [-e|--elan] [-E|--exmaralda] [-k KC2TEI_CONVERTER_SCRIPT] [-c KCTEI_XML_CONVERTER_SCRIPT] [-o OUT_DIR|--output OUT_DIR] [-v] INPUT_FILE

  Script converts INPUT_FILE into KCTEI format using the kc2tei converter
  and converts the resulting file into several other formats.

    [-h|--help]      show this output

    [-t|--praat]     convert into TextGrid (praat) format

    [-e|--elan]      convert into eaf (ELAN) format

    [-E|--exmaralda] convert into exb (EXMARaLDA) format

    [-k KC2TEI_CONVERTER_SCRIPT]     use this KC2TEI_CONVERTER_SCRIPT instead of the default

    [-c KCTEI_XML_CONVERTER_SCRIPT]  use this KCTEI_XML_CONVERTER_SCRIPT instead of the default

    [-o OUT_DIR|--output OUT_DIR]    place output files in OUT_DIR

    [-v|--verbose]             some verbose information


  If no output format is given, all defined output formats are used.

  If no output root directory is given, output files will be placed
  in the same directory as the input file resides in.

END
}

IN_FILE=
OUT_ROOT_DIR=

VERBOSE=0

while [ $# -gt 0 ]; do
  case $1 in
    -t|--praat)
      OUT_FORMATS="$OUT_FORMATS -t"
    ;;
    -e|--elan)
      OUT_FORMATS="$OUT_FORMATS -e"
    ;;
    -E|--exmaralda)
      OUT_FORMATS="$OUT_FORMATS -E"
    ;;
    -k)
      KCTEI_CONVERTER="$2"
      shift
    ;;
    -c)
      KCTEI_XML_CONVERTER="$2"
      shift
    ;;
    -o|--output)
      OUT_ROOT_DIR=$2
      shift
    ;;
    -v|--verbose)
      VERBOSE=1
    ;;
    -h|--help)
      usage
      exit
    ;;
    *)
      IN_FILE=$1
    ;;
  esac
  shift
done

if [ "$IN_FILE" = "" ]; then
  echo "ERROR: Input file not specified!"
  echo "Exitting ..."
  exit 1
fi

if [ ! -f "$IN_FILE" ]; then
  echo "ERROR: Input file $IN_FILE not found!"
  echo "Exitting ..."
  exit 1
fi

if [ "$KCTEI_CONVERTER" = "" ]; then
  KCTEI_CONVERTER=$KCTEI_CONVERTER_DEFAULT
fi

if [ ! -e "$KCTEI_CONVERTER" ]; then
  echo "ERROR: kc2tei converter script $KCTEI_CONVERTER not found!"
  echo "Exitting ..."
  exit 1
fi

if [ "$KCTEI_XML_CONVERTER" = "" ]; then
  KCTEI_XML_CONVERTER=$KCTEI_XML_CONVERTER_DEFAULT
fi

if [ ! -e "$KCTEI_XML_CONVERTER" ]; then
  echo "ERROR: kctei XML converter script $KCTEI_XML_CONVERTER not found!"
  echo "Exitting ..."
  exit 1
fi

if [ "$OUT_ROOT_DIR" = "" ]; then
  OUT_ROOT_DIR=$( dirname "$IN_FILE" )
fi

if [ ! -d "$OUT_ROOT_DIR" ]; then
  echo "ERROR: output root directory does not exist!"
  echo "Exitting ..."
  exit 1
fi

if [ "$OUT_FORMATS" = "" ]; then
  OUT_FORMATS="-t -e -E"
fi

if [ $VERBOSE -eq 1 ]; then
  echo
  echo "kc2tei converter script: $KCTEI_CONVERTER"
  echo "kctei XML converter script: $KCTEI_XML_CONVERTER"
  echo
  echo "Input file: $IN_FILE"
  echo "Output dir: $OUT_ROOT_DIR"
  echo "Output formats: $OUT_FORMATS"
  echo
fi

BASE_FILENAME=$( basename "$IN_FILE" | rev | cut -d . -f 2- | rev )

XML_FILE="${OUT_ROOT_DIR}/${BASE_FILENAME}.xml"

echo "Converting $IN_FILE into $XML_FILE ..."
OUT=$( $KCTEI_CONVERTER -i "$IN_FILE" 2>&1 )
if [ $? -ne 0 ]; then
  echo "ERROR while converting!"
  echo "$OUT"
  echo "Exitting ..."
  exit 1
else
  echo "$OUT" > "$XML_FILE"
fi

echo "Converting $XML_FILE ..."
$KCTEI_XML_CONVERTER $OUT_FORMATS -o $OUT_ROOT_DIR "$XML_FILE"
if [ $? -ne 0 ]; then
  echo "Error while converting!"
  echo "Exitting ..."
  exit 1
fi

