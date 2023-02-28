
setup () {
    load 'test_helper/common_setup'
    _common_setup
    TEST_NAME='test_utils_tasks'
    COMPARISON_LOG_NAME="$DIR/logs/${TEST_NAME}_file_comparison.log"
}

setup_file () {
    setup

    # delete old log file
    rm -rf "$COMPARISON_LOG_NAME"

    # generate input file from template
    run "$SCRIPTS_DIR"/venv/bin/generate_cromwell_inputs \
        -o "$DIR"/cromwell/inputs/"$TEST_NAME".json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/inputs_template.json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/inputs.json
}

# bats file_tags=utils
# bats test_tags=workflow
@test "test_utils_tasks workflow runs sucessfully" {

    # clean up cromwell dir
    rm -rf $DIR/cromwell/cromwell-executions/"$TEST_NAME"/*

    # check if we can run the workflow
    cd $TEST_WDL_DIR
    run womtool validate -i "$DIR"/cromwell/inputs/"$TEST_NAME".json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/"$TEST_NAME".wdl
    assert_success

    # run workflow
    cd "$DIR"/cromwell
    run cromwell run -o options/common.json --imports "$TEST_WDL_DIR"/common.zip \
        -m metadata/"$TEST_NAME".json --inputs "$DIR"/cromwell/inputs/"$TEST_NAME".json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/"$TEST_NAME".wdl

    echo -e "$output" > "$DIR"/cromwell/cromwell-workflow-logs/"$TEST_NAME".log
    assert_success
}

# bats test_tags=check
@test "Check dirname_url_test output" {
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/dirname_url_test"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        -e "$target_dir"/stdout \
        "$workflow_root/call-dirname_url_test/execution"
    echo -e "${BATS_TEST_NAME}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

# bats test_tags=check
@test "Check dirname_real_file_test output" {
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/dirname_real_file_test"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        -e "$target_dir"/stdout \
        "$workflow_root/call-dirname_real_file_test/execution"
    echo -e "${BATS_TEST_NAME}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

# bats test_tags=check
@test "Check dirname_fake_file_test output" {
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/dirname_fake_file_test"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        -e "$target_dir"/stdout \
        "$workflow_root/call-dirname_fake_file_test/execution"
    echo -e "${BATS_TEST_NAME}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

# bats test_tags=check
@test "Check subset_fixed output" {
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/subset_fixed"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        -e "$target_dir"/filter.txt \
        -e "$target_dir"/subset_all_files.txt \
        "$workflow_root/call-subset_fixed/execution"
    echo -e "${BATS_TEST_NAME}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

# bats test_tags=check
@test "Check subset_regex output" {
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/subset_regex"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        -e "$target_dir"/filter.txt \
        -e "$target_dir"/subset_all_files.txt \
        "$workflow_root/call-subset_regex/execution"
    echo -e "${BATS_TEST_NAME}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

# bats test_tags=check
@test "Check subset_inversed output" {
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/subset_inversed"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        -e "$target_dir"/filter.txt \
        -e "$target_dir"/subset_all_files.txt \
        "$workflow_root/call-subset_inversed/execution"
    echo -e "${BATS_TEST_NAME}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

# bats test_tags=check
@test "Check subset_with_header output" {
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/subset_with_header"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        -e "$target_dir"/filter.txt \
        -e "$target_dir"/subset_all_files.txt \
        "$workflow_root/call-subset_with_header/execution"
    echo -e "${BATS_TEST_NAME}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

