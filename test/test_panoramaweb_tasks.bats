
setup () {
    load 'test_helper/common_setup'
    _common_setup
    COMPARISON_LOG_NAME="$DIR/logs/${TEST_NAME}_file_comparison.log"
}

setup_file () {
    setup
    rm -rf "$COMPARISON_LOG_NAME"
}

# bats file_tags=panorama
# bats test_tags=workflow
@test "test_panorama_list_files workflow runs sucessfully" {
    rm -rf $DIR/cromwell/cromwell-executions/test_panorama_list_files/*
    cd "$DIR"/cromwell
    run cromwell run -m metadata/test_panoramaweb_tasks.json -o options/common.json --imports "$TEST_WDL_DIR"/common.zip "$TEST_WDL_DIR"/test_panoramaweb_tasks.wdl
    echo -e "$output" > "$DIR"/cromwell/cromwell-workflow-logs/test_panoramaweb_tasks.log
    assert_success
}

# bats test_tags=check
@test "Check test_file_ext output" {
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/test_panoramaweb_tasks.json)
    target_dir="${PROJECT_ROOT}/test/data/test_panorama_list_files/test_file_ext"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
                                              -e "$target_dir"/file_list.txt \
                                              -e "$target_dir"/url_list.txt \
                                              -e "$target_dir"/all_files.txt \
                                              "$workflow_root/call-test_file_ext/execution"
    echo -e "${BATS_TEST_NAME}\n${BATS_RUN_COMMAND}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

# bats test_tags=check
@test "Check test_list_files_with_limit output" {
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/test_panoramaweb_tasks.json)
    target_dir="${PROJECT_ROOT}/test/data/test_panorama_list_files/test_list_files_with_limit"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
                                              -e "$target_dir"/file_list.txt \
                                              -e "$target_dir"/url_list.txt \
                                              -e "$target_dir"/all_files.txt \
                                              "$workflow_root/call-test_list_files_with_limit/execution"
    echo -e "${BATS_TEST_NAME}\n${BATS_RUN_COMMAND}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

# bats test_tags=check
@test "Check test_list_files_without_limit output" {
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/test_panoramaweb_tasks.json)
    target_dir="${PROJECT_ROOT}/test/data/test_panorama_list_files/test_list_files_without_limit"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
                                              -e "$target_dir"/file_list.txt \
                                              -e "$target_dir"/url_list.txt \
                                              -e "$target_dir"/all_files.txt \
                                              "$workflow_root/call-test_list_files_without_limit/execution"
    echo -e "${BATS_TEST_NAME}\n${BATS_RUN_COMMAND}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

