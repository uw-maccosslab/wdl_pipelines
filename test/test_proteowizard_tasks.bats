
setup () {
    load 'test_helper/common_setup'
    _common_setup
    TEST_NAME='test_proteowizard_tasks'

    # generate input file from template
    run python3 "$SCRIPTS_DIR"/generate_cromwell_inputs.py \
        -o "$DIR"/cromwell/inputs/"$TEST_NAME".json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/inputs_template.json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/inputs.json
}

# bats file_tags=proteowizard
# bats test_tags=setup
@test "test_can_run_workflow" {
    cd $TEST_WDL_DIR
    run womtool validate -i "$DIR"/cromwell/inputs/"$TEST_NAME".json "$TEST_WDL_DIR"/test_proteowizard_tasks/test_proteowizard_tasks.wdl
    assert_success
}

# bats file_tags=proteowizard
# bats test_tags=workflow
@test "test_proteowizard_list_files workflow runs sucessfully" {

    # clean up cromwell dir
    rm -rf $DIR/cromwell/cromwell-executions/test_proteowizard_tasks/*
    cd "$DIR"/cromwell

    # run workflow
    run cromwell run -o options/common.json --imports "$TEST_WDL_DIR"/common.zip \
        -m metadata/"$TEST_NAME".json --inputs "$DIR"/cromwell/inputs/"$TEST_NAME".json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/"$TEST_NAME".wdl

    echo "run cromwell run -o options/common.json --imports $TEST_WDL_DIR/common.zip -m metadata/$TEST_NAME.json --inputs $TEST_WDL_DIR/$TEST_NAME/$TEST_NAME.wdl"

    echo -e "$output" > "$DIR"/cromwell/cromwell-workflow-logs/"$TEST_NAME".log
    assert_success
}

# # bats test_tags=chec
# @test "Check test_file_ext output" {
#     workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/"$TEST_NAME".json)
#     target_dir="${PROJECT_ROOT}/test/data/test_proteowizard_list_files/test_file_ext"
#     run python3 "$DIR"/compare_cromwell_output.py -e "$target_dir"/rc \
#                                               -e "$target_dir"/file_list.txt \
#                                               -e "$target_dir"/url_list.txt \
#                                               -e "$target_dir"/all_files.txt \
#                                               "$workflow_root/call-test_file_ext/execution"
#     assert_success
# }
