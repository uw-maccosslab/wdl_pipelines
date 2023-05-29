
setup () {
    load 'test_helper/common_setup'
    _common_setup
    TEST_NAME='test_msconvert_tasks'
    COMPARISON_LOG_NAME="$DIR/logs/${TEST_NAME}_file_comparison.log"
}

setup_file () {
    setup

    # delete old log file
    rm -rf "$COMPARISON_LOG_NAME"
}

# bats file_tags=proteowizard
# bats test_tags=workflow
@test "test_msconvert_tasks workflow runs sucessfully" {

    # generate input file from template
    run "$SCRIPTS_DIR"/venv/bin/generate_cromwell_inputs \
        -o "$DIR"/cromwell/inputs/"$TEST_NAME".json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/inputs_template.json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/inputs.json

    # check if we can run the workflow
    cd $TEST_WDL_DIR
    run womtool validate -i "$DIR"/cromwell/inputs/"$TEST_NAME".json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/"$TEST_NAME".wdl
    assert_success

    # clean up cromwell dir
    previous_workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/"$TEST_NAME".json)
    if [[ -d "$previous_workflow_root" ]] ; then
        rm -rf "$previous_workflow_root"
    fi

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

# bats file_tags=proteowizard
# bats test_tags=workflow, failing
@test "test_msconvert_bad_file_type workflow fails sucessfully" {
    
    failing_workflow_name='test_msconvert_bad_file_type'
    
    # generate input file from template
    run "$SCRIPTS_DIR"/venv/bin/generate_cromwell_inputs \
        -o "$DIR"/cromwell/inputs/"$failing_workflow_name".json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/failing_inputs_template.json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/failing_inputs.json

    # check if we can run the workflow
    cd $TEST_WDL_DIR
    run womtool validate -i "$DIR"/cromwell/inputs/"$failing_workflow_name".json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/"$failing_workflow_name".wdl
    assert_success

    # clean up cromwell dir
    previous_workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/"$failing_workflow_name".json)
    if [[ -d "$previous_workflow_root" ]] ; then
        rm -rf "$previous_workflow_root"
    fi

    # run workflow
    cd "$DIR"/cromwell
    run cromwell run -o options/common.json --imports "$TEST_WDL_DIR"/common.zip \
        -m metadata/"$failing_workflow_name".json \
        --inputs "$DIR"/cromwell/inputs/"$failing_workflow_name".json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/"$failing_workflow_name".wdl

    echo -e "$output" > "$DIR"/cromwell/cromwell-workflow-logs/"$failing_workflow_name".log
    assert_failure
}

