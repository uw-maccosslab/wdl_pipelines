
setup () {
    load 'test_helper/common_setup'
    _common_setup
    TEST_NAME='test_skyline_tasks'

    # delete old log file
    COMPARISON_LOG_NAME="$DIR/logs/${TEST_NAME}_file_comparison.log"
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

# bats file_tags=proteowizard
# bats test_tags=check
@test "Check export_precursor_report output" {
    task_name='export_precursor_report'
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/$task_name"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        --addTsv "$target_dir"/precursor_quality.tsv \
        "$workflow_root/call-$task_name/execution"
    echo "$output" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

# bats file_tags=proteowizard
# bats test_tags=check
@test "Check export_peptide_report output" {
    task_name='export_peptide_report'
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/$task_name"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        --addTsv "$target_dir"/peptide_abundance_long.tsv \
        "$workflow_root/call-$task_name/execution"
    echo "$output" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

# bats file_tags=proteowizard
# bats test_tags=check
@test "Check export_protein_report output" {
    task_name='export_protein_report'
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/$task_name"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        --addTsv "$target_dir"/protein_abundance_long.tsv \
        "$workflow_root/call-$task_name/execution"
    echo "$output" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}
