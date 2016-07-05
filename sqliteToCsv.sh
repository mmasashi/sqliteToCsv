#!/bin/bash
# Copyright (c) 2011 mmasashi
# 
# License:     MIT
# Permission is hereby granted, free of charge, to any person obtaining a copy 
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights 
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


usage() {
  echo "Usage: sh sqliteToCsv.sh [sqlitepath] ([outputdir, default=output])"
  exit 1
}

###### parameter
# sqlite path
SQLITE_PATH=""
if [ "$1" != "" ]; then
  SQLITE_PATH="$1"
else
  usage
fi

# output directory
OUTPUT_DIR="output"
if [ "$2" != "" ]; then
  OUTPUT_DIR="$2"
fi
mkdir -p "$OUTPUT_DIR"


###### sqlite to csv
for TARGET in `sqlite3 "$SQLITE_PATH" ".tables"`
do
  OUTPUT_FILE="$OUTPUT_DIR/$TARGET.csv"

  DATA_NUM=`sqlite3 "$SQLITE_PATH" "select count(*) from $TARGET"`
  if [ $DATA_NUM -lt 1 ]; then
    echo "Table:$TARGET DataNum:${DATA_NUM}"
    echo "No data" > $OUTPUT_FILE
  else
    CLM_NUM=`sqlite3 -header "$SQLITE_PATH" "select * from $TARGET" \
            | awk 'BEGIN{FS="|"}{if (NR==1) print NF}'`
    echo "Table:$TARGET DataNum:${DATA_NUM} \
ColNum:${CLM_NUM}"
    if [ $CLM_NUM -lt 1 ]; then
      echo "No columns" > $OUTPUT_FILE
    else 
      # sort 
      ORDER_RULE="1"
      for (( a=2; a<=$CLM_NUM; a++ ))
      do
        ORDER_RULE="${ORDER_RULE},$a"
      done
      sqlite3 -header -separator "," "$SQLITE_PATH" "select * from $TARGET \
order by $ORDER_RULE" > $OUTPUT_FILE
    fi
  fi
done

if [ "$OUTPUT_FILE" = "" ]; then
  echo "No tables..."
else
  echo "Done."
fi
