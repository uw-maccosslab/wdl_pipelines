
_common_setup () {
    # load bats 
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'

    # set up directory variables
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    TEST_WDL_DIR="$DIR/wdl/"
    PROJECT_ROOT="$(realpath $DIR/../)"
    SCRIPTS_DIR="$DIR/scripts/"
    WDL_DIR="$PROJECT_ROOT/wdl/"
}

_copy_common () {
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    TEST_WDL_DIR="$DIR/wdl/"
    PROJECT_ROOT="$(realpath $DIR/../)"
    WDL_DIR="$PROJECT_ROOT/wdl/"
    SCRIPTS_DIR="$DIR/scripts/"

    # copy common wdl files into zip archive in test directory
    cp -vr "$WDL_DIR"/common "$TEST_WDL_DIR" > "$DIR"/logs/cp_common.log
    cd "$TEST_WDL_DIR"
    echo "Processing import urls..." > "$DIR"/logs/process_import_urls.log
    for f in $(find common -type f|grep '\.wdl$') ; do
        echo >> "$DIR"/logs/process_import_urls.log
        echo "$SCRIPTS_DIR"/venv/bin/process_import_urls '--inPlace' \
            '--logFile' "\"$DIR/logs/process_import_urls.log\"" \
            '"https://raw.githubusercontent.com/uw-maccosslab/wdl_pipelines/master/wdl/"' \
            "\"$f\"" >> "$DIR"/logs/process_import_urls.log
        "$SCRIPTS_DIR"/venv/bin/process_import_urls --inPlace \
            --logFile "$DIR"/logs/process_import_urls.log \
            'https://raw.githubusercontent.com/uw-maccosslab/wdl_pipelines/master/wdl/' \
            "$f"
    done
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


