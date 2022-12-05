
setup () {
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    WDL_DIRNAME="$DIR/../wdl/"
}

@test "skyline_import_search workflow has valid syntax" {
    run womtool validate -i "$WDL_DIRNAME"/common/proteowizard/input_template.json "$WDL_DIRNAME"/common/proteowizard/proteowizard.wdl
}

