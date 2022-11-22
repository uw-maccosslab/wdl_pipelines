
setup () {
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    TEST_WDL_DIRNAME="$DIR/wdl/"
    cp -vr "$DIR"/../wdl/common "$TEST_WDL_DIRNAME" > "$DIR"/logs/cp_common.log
    cd "$TEST_WDL_DIRNAME"
    zip -r common common/*.wdl > "$DIR"/logs/zip_common.log
}

@test "PanoramaWeb test workflow has valid syntax" {
    womtool validate "$TEST_WDL_DIRNAME"/test_panoramaweb_tasks.wdl
}

# @test "PanoramaWeb tasks exit sucessfully" {
#     # cromwell -
# }

