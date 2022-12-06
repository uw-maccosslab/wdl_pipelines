
setup () {
    load 'test_helper/common_setup'
    _common_setup
}

@test "skyline_import_search workflow has valid syntax" {
    run womtool validate -i "$WDL_DIRNAME"/common/proteowizard/skyline_import_search_input_template.json "$WDL_DIRNAME"/common/proteowizard/proteowizard.wdl
    assert_success
}

