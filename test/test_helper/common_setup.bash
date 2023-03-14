
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
    echo "Processing import urls..." > "$DIR"/logs/process_common_import_urls.log
    for f in $(find common -type f|grep '\.wdl$') ; do
        echo >> "$DIR"/logs/process_common_import_urls.log
        "$SCRIPTS_DIR"/venv/bin/process_import_urls --inPlace \
            --logFile "$DIR"/logs/process_common_import_urls.log \
            'https://raw.githubusercontent.com/uw-maccosslab/wdl_pipelines/master/wdl/' \
            "$f"
    done
    find common -type f| grep '\.wdl$'| zip -@ common.zip > "$DIR"/logs/zip_common.log
}

_copy_pipelines () {
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    TEST_WDL_DIR="$DIR/wdl/"
    PROJECT_ROOT="$(realpath $DIR/../)"
    WDL_DIR="$PROJECT_ROOT/wdl"
    SCRIPTS_DIR="$DIR/scripts/"
    WDL_PIPELINES_DIRNAME="dev_wdl_pipelines"
     
    for f in $(find "${WDL_DIR}/${WDL_PIPELINES_DIRNAME}" -type f| grep '\.json$') ; do
        d=$(basename $(dirname "$f")) && \
            mkdir -vp "${TEST_WDL_DIR}/pipelines/${d}" && \
            cp -v "$f" "${TEST_WDL_DIR}/pipelines/${d}"
    done > "$DIR"/logs/cp_pipelines.log

    echo "Processing import urls..." > "$DIR"/logs/process_pipeline_import_urls.log
    for f in $(find "${WDL_DIR}/${WDL_PIPELINES_DIRNAME}" -type f|grep '\.wdl$') ; do
        echo >> "$DIR"/logs/process_pipeline_import_urls.log
        f_b=$(basename "$f") && \
        d=$(basename $(dirname "$f")) && \
        "$SCRIPTS_DIR"/venv/bin/process_import_urls \
            '--logFile' "$DIR/logs/process_pipeline_import_urls.log" \
            'https://raw.githubusercontent.com/uw-maccosslab/wdl_pipelines/master/wdl/' \
            "$f" > "${TEST_WDL_DIR}/pipelines/${d}/${f_b}"
    done
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


