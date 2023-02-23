
setup () {
    load 'test_helper/common_setup'
    _common_setup
    TEST_NAME='test_msconvert_tasks'

    # generate input file from template
    run python3 "$SCRIPTS_DIR"/generate_cromwell_inputs.py \
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

# bats file_tags=proteowizard
# bats test_tags=check
@test "Check test_generate_overlapping_config output" {
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/test_generate_overlapping_config"
    run python3 "$SCRIPTS_DIR"/compare_cromwell_output.py -e "$target_dir"/rc \
        -e "$target_dir"/msconvert_params.txt \
        "$workflow_root/call-test_generate_overlapping_config/execution"
    assert_success
}

# bats file_tags=proteowizard
# bats test_tags=check
@test "Check test_generate_non_overlapping_config output" {
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/test_generate_non_overlapping_config"
    run python3 "$SCRIPTS_DIR"/compare_cromwell_output.py -e "$target_dir"/rc \
        -e "$target_dir"/msconvert_params.txt \
        "$workflow_root/call-test_generate_non_overlapping_config/execution"
    assert_success
}
