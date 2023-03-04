
setup () {
    load 'test_helper/common_setup'
    _common_setup
    TEST_NAME='test_msconvert_tasks'
    COMPARISON_LOG_NAME="$DIR/logs/${TEST_NAME}_file_comparison.log"
}

setup_file () {
    setup
    _copy_files

    # delete old log file
    rm -rf "$COMPARISON_LOG_NAME"

    # generate input file from template
    run "$SCRIPTS_DIR"/venv/bin/generate_cromwell_inputs \
        -o "$DIR"/cromwell/inputs/"$TEST_NAME".json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/inputs_template.json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/inputs.json
}

# bats file_tags=proteowizard
# bats test_tags=workflow
@test "test_msconvert_tasks workflow runs sucessfully" {

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
@test "Check test_generate_overlapping_config output" {
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/test_generate_overlapping_config"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        -e "$target_dir"/msconvert_params.txt \
        "$workflow_root/call-test_generate_overlapping_config/execution"
    echo -e "${BATS_TEST_NAME}\n${BATS_RUN_COMMAND}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

# bats test_tags=check
@test "Check test_generate_non_overlapping_config output" {
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/test_generate_non_overlapping_config"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        -e "$target_dir"/msconvert_params.txt \
        "$workflow_root/call-test_generate_non_overlapping_config/execution"
    echo -e "${BATS_TEST_NAME}\n${BATS_RUN_COMMAND}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

