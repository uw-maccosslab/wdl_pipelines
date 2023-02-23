
setup () {
    load 'test_helper/common_setup'
    _common_setup
}

@test "skyline_import_search workflow has valid syntax" {
    run womtool validate -i "$WDL_DIR"/common/proteowizard/skyline_import_search_input_template.json "$WDL_DIR"/common/proteowizard/proteowizard.wdl
    assert_success
}

@test "test_panorama_list_files workflow has valid syntax" {
    run womtool validate "$TEST_WDL_DIR"/test_panoramaweb_tasks.wdl
    assert_success
}

@test "test_proteowizard_tasks workflow has valid syntax" {
    run womtool validate "$TEST_WDL_DIR"/test_proteowizard_tasks/test_proteowizard_tasks.wdl
    assert_success
}
