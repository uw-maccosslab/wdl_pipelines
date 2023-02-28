
_common_setup () {
    # load bats 
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'

    # set up directory variables
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    TEST_WDL_DIR="$DIR/wdl/"
    PROJECT_ROOT="$(realpath $DIR/../)"
    WDL_DIR="$PROJECT_ROOT/wdl/"
    SCRIPTS_DIR="$DIR/scripts/"

    # copy common wdl files into zip archive in test directory
    cp -vr "$WDL_DIR"/common "$TEST_WDL_DIR" > "$DIR"/logs/cp_common.log
    cd "$TEST_WDL_DIR"
    find common -type f| grep '\.wdl$'| zip -@ common.zip > "$DIR"/logs/zip_common.log
}

check_state () {
    if [ $1 == 0 ]; then
        return 0
    else
        kill $PPID
        return $status
    fi
}

get_workflow_root () {
    script="
import json
import os

if os.path.isfile(\"$1\"):
    with open(\"$1\", 'r') as inF:
        d = json.load(inF)
    print(d['workflowRoot'])
    "
    python -c "$script"
}


