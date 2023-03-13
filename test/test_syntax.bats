
setup_file () {
    load 'test_helper/common_setup'
    _copy_common
}

setup () {
    load 'test_helper/common_setup'
    _common_setup
}

# bats file_tags=syntax
# bats test_tags=proteowizard
@test "skyline_import_search workflow has valid syntax" {
    cd "$TEST_WDL_DIR"
    run womtool validate -i "$WDL_DIR"/common/proteowizard/skyline_import_search_input_template.json "$WDL_DIR"/common/proteowizard/proteowizard.wdl
    assert_success
}

# bats test_tags=panorama
@test "test_panorama_list_files workflow has valid syntax" {
    run womtool validate "$TEST_WDL_DIR"/test_panoramaweb_tasks.wdl
    assert_success
}

# bats test_tags=proteowizard
@test "test_msconvert_tasks workflow has valid syntax" {
    cd "$TEST_WDL_DIR"
    run womtool validate -i "$TEST_WDL_DIR"/test_msconvert_tasks/inputs.json "$TEST_WDL_DIR"/test_msconvert_tasks/test_msconvert_tasks.wdl
    assert_success
}

# bats test_tags=proteowizard, full
@test "Full test_skyline_tasks workflow has valid syntax" {
    cd "$TEST_WDL_DIR"
    run womtool validate -i "$TEST_WDL_DIR"/test_skyline_tasks/full_inputs.json "$TEST_WDL_DIR"/test_skyline_tasks/test_skyline_tasks.wdl
    assert_success
}

# bats test_tags=proteowizard, partial
@test "Partial test_skyline_tasks workflow has valid syntax" {
    cd "$TEST_WDL_DIR"
    run womtool validate -i "$TEST_WDL_DIR"/test_skyline_tasks/partial_inputs.json "$TEST_WDL_DIR"/test_skyline_tasks/test_skyline_tasks.wdl
    assert_success
}

# bats test_tags=utils
@test "Partial test_utils_tasks workflow has valid syntax" {
    cd "$TEST_WDL_DIR"
    run womtool validate -i "$TEST_WDL_DIR"/test_utils_tasks/inputs.json "$TEST_WDL_DIR"/test_utils_tasks/test_utils_tasks.wdl
    assert_success
}

# bats test_tags=file_interface
@test "local test_file_interface_tasks workflow has valid syntax" {
    cd "$TEST_WDL_DIR"
    run womtool validate -i "$TEST_WDL_DIR"/test_file_interface_tasks/local_inputs.json \
        "$WDL_DIR"/common/file_interface/file_interface.wdl
    assert_success
}

