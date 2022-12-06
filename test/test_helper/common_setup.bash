
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
    zip -r common common/*.wdl > "$DIR"/logs/zip_common.log
}
