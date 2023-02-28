
setup () {
    load 'test_helper/common_setup'
    _common_setup
    TEST_NAME='test_skyline_tasks'
    COMPARISON_LOG_NAME="$DIR/logs/${TEST_NAME}_file_comparison.log"
}

setup_file () {
    setup
    rm -rf "$COMPARISON_LOG_NAME"
}

# bats file_tags=proteowizard
# bats test_tags=workflow, full
@test "Full test skyline workflow runs sucessfully" {

    # generate input files from template
    run "$SCRIPTS_DIR"/venv/bin/generate_cromwell_inputs \
        -o "$DIR"/cromwell/inputs/full_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/full_inputs_template.json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/full_inputs.json

    # check if we can run the workflow
    cd $TEST_WDL_DIR
    run womtool validate -i "$DIR"/cromwell/inputs/full_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/"$TEST_NAME".wdl
    assert_success

    # clean up cromwell dir
    previous_workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/full_"$TEST_NAME".json)
    if [[ -d "$previous_workflow_root" ]] ; then
        rm -rf "$previous_workflow_root"
    fi

    # run workflow
    cd "$DIR"/cromwell
    run cromwell run -o options/common.json --imports "$TEST_WDL_DIR"/common.zip \
        -m metadata/full_"$TEST_NAME".json --inputs "$DIR"/cromwell/inputs/full_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/"$TEST_NAME".wdl

    echo -e "$output" > "$DIR"/cromwell/cromwell-workflow-logs/"$TEST_NAME".log
    assert_success
}

# bats test_tags=check, full
@test "Check full export_precursor_report output" {
    task_name='export_precursor_report'
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/full_"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/$task_name"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        --addTsv "$target_dir"/precursor_quality.tsv \
        "$workflow_root/call-$task_name/execution"
    echo -e "${BATS_TEST_NAME}\n${BATS_RUN_COMMAND}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

# bats test_tags=check, full
@test "Check full export_peptide_report output" {
    task_name='export_peptide_report'
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/full_"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/$task_name"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        --addTsv "$target_dir"/peptide_abundance_long.tsv \
        "$workflow_root/call-$task_name/execution"
    echo -e "${BATS_TEST_NAME}\n${BATS_RUN_COMMAND}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

# bats test_tags=check, full
@test "Check full export_protein_report output" {
    task_name='export_protein_report'
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/full_"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/$task_name"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        --addTsv "$target_dir"/protein_abundance_long.tsv \
        "$workflow_root/call-$task_name/execution"
    echo -e "${BATS_TEST_NAME}\n${BATS_RUN_COMMAND}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

# bats test_tags=workflow, partial
@test "Partial test skyline workflow runs sucessfully" {
    
    # generate input files from template
    run "$SCRIPTS_DIR"/venv/bin/generate_cromwell_inputs \
        -o "$DIR"/cromwell/inputs/partial_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/partial_inputs_template.json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/partial_inputs.json
    assert_success

    # check if we can run the workflow
    cd $TEST_WDL_DIR
    run womtool validate -i "$DIR"/cromwell/inputs/partial_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/"$TEST_NAME".wdl
    assert_success

    # clean up cromwell dir
    previous_workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/partial_"$TEST_NAME".json)
    if [[ -d "$previous_workflow_root" ]] ; then
        rm -rf "$previous_workflow_root"
    fi

    # run workflow
    cd "$DIR"/cromwell
    run cromwell run -o options/common.json --imports "$TEST_WDL_DIR"/common.zip \
        -m metadata/partial_"$TEST_NAME".json --inputs "$DIR"/cromwell/inputs/partial_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/"$TEST_NAME".wdl

    echo -e "$output" > "$DIR"/cromwell/cromwell-workflow-logs/"$TEST_NAME".log
    assert_success
}

# bats test_tags=check, partial
@test "Check partial export_precursor_report output" {
    task_name='export_precursor_report'
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/partial_"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/$task_name"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        --addTsv "$target_dir"/precursor_quality.tsv \
        "$workflow_root/call-$task_name/execution"
    echo -e "${BATS_TEST_NAME}\n${BATS_RUN_COMMAND}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

# bats test_tags=check, partial
@test "Check partial export_peptide_report output" {
    task_name='export_peptide_report'
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/partial_"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/$task_name"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        --addTsv "$target_dir"/peptide_abundance_long.tsv \
        "$workflow_root/call-$task_name/execution"
    echo -e "${BATS_TEST_NAME}\n${BATS_RUN_COMMAND}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

# bats test_tags=check, partial
@test "Check partial export_protein_report output" {
    task_name='export_protein_report'
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/partial_"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/$task_name"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        --addTsv "$target_dir"/protein_abundance_long.tsv \
        "$workflow_root/call-$task_name/execution"
    echo -e "${BATS_TEST_NAME}\n${BATS_RUN_COMMAND}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

