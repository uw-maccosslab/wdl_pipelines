
_common_setup () {
    # load bats 
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'

    # set up directory variables
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    TEST_WDL_DIRNAME="$DIR/wdl/"
    PROJECT_ROOT="$DIR/../"
    WDL_DIRNAME="$PROJECT_ROOT/wdl/"

    # copy common wdl files into zip archive in test directory
    cp -vr "$WDL_DIRNAME"/common "$TEST_WDL_DIRNAME" > "$DIR"/logs/cp_common.log
    cd "$TEST_WDL_DIRNAME"
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
with open(\"$1\", 'r') as inF:
    d = json.load(inF)
print(d['workflowRoot'])
    "
    python -c "$script"
}


