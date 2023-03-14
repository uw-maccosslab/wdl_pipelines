
setup_file () {
    load 'test_helper/common_setup'
    _copy_common
    _copy_pipelines
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
        "$TEST_WDL_DIR"/common/file_interface/get_ms_data_files.wdl
    assert_success
}

# bats test_tags=pipeline
@test "Panorama_Msconvert workflow has valid syntax" {
    cd "$TEST_WDL_DIR"
    run womtool validate -i "$TEST_WDL_DIR"/pipelines/Panorama_Msconvert/input_template.json \
        "$TEST_WDL_DIR"/pipelines/Panorama_Msconvert/workflow.wdl
    assert_success
}

# bats test_tags=pipeline
@test "DIA_PDC_DiaNN workflow has valid syntax" {
    cd "$TEST_WDL_DIR"
    run womtool validate -i "$TEST_WDL_DIR"/pipelines/DIA_PDC_DiaNN/input_template.json \
        "$TEST_WDL_DIR"/pipelines/DIA_PDC_DiaNN/workflow.wdl
    assert_success
}

# bats test_tags=pipeline
@test "DIA_PDC_EncyclopeDIA workflow has valid syntax" {
    cd "$TEST_WDL_DIR"
    run womtool validate -i "$TEST_WDL_DIR"/pipelines/DIA_PDC_EncyclopeDIA/input_template.json \
        "$TEST_WDL_DIR"/pipelines/DIA_PDC_EncyclopeDIA/workflow.wdl
    assert_success
}

# bats test_tags=pipeline
@test "DIA_Panorama_EncyclopeDIA workflow has valid syntax" {
    cd "$TEST_WDL_DIR"
    run womtool validate -i "$TEST_WDL_DIR"/pipelines/DIA_Panorama_EncyclopeDIA/input_template.json \
        "$TEST_WDL_DIR"/pipelines/DIA_Panorama_EncyclopeDIA/workflow.wdl
    assert_success
}

@test "DIA_Panorama_DiaNN workflow has valid syntax" {
    cd "$TEST_WDL_DIR"
    run womtool validate -i "$TEST_WDL_DIR"/pipelines/DIA_Panorama_DiaNN/input_template.json \
        "$TEST_WDL_DIR"/pipelines/DIA_Panorama_DiaNN/workflow.wdl
    assert_success
}
