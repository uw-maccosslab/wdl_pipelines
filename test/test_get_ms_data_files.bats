
setup () {
    load 'test_helper/common_setup'
    _common_setup
    TEST_NAME='test_get_ms_data_files'
    COMPARISON_LOG_NAME="$DIR/logs/${TEST_NAME}_file_comparison.log"
}

setup_file () {
    setup
    _copy_common
    rm -rf "$COMPARISON_LOG_NAME"
}

# bats file_tags=file_interface
# bats test_tags=workflow, local
@test "Local get_ms_data_files workflow runs sucessfully" {

    # generate input files from template
    run "$SCRIPTS_DIR"/venv/bin/generate_cromwell_inputs \
        -o "$DIR"/cromwell/inputs/local_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/local_inputs_template.json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/local_inputs.json
    assert_success

    # check if we can run the workflow
    cd $TEST_WDL_DIR
    run womtool validate -i "$DIR"/cromwell/inputs/local_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/common/file_interface/get_ms_data_files.wdl
    assert_success

    # clean up cromwell dir
    previous_workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/local_"$TEST_NAME".json)
    if [[ -d "$previous_workflow_root" ]] ; then
        rm -rf "$previous_workflow_root"
    fi

    # run workflow
    cd "$DIR"/cromwell
    run cromwell run -o options/common.json --imports "$TEST_WDL_DIR"/common.zip \
        -m metadata/local_"$TEST_NAME".json --inputs "$DIR"/cromwell/inputs/local_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/common/file_interface/get_ms_data_files.wdl

    echo -e "$output" > "$DIR"/cromwell/cromwell-workflow-logs/local_"$TEST_NAME".log
    assert_success
}

# bats test_tags=check, local
@test "Check list_local_wide_files output" {
    task_name='list_local_wide_files'
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/local_"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/$task_name"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        -e "$target_dir"/files.txt \
        "$workflow_root/call-$task_name/execution"
    echo -e "${BATS_TEST_NAME}\n${BATS_RUN_COMMAND}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

# bats test_tags=check, local
@test "Check list_local_narrow_files output" {
    task_name='list_local_narrow_files'
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/local_"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/$task_name"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        -e "$target_dir"/files.txt \
        "$workflow_root/call-$task_name/execution"
    echo -e "${BATS_TEST_NAME}\n${BATS_RUN_COMMAND}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

# bats file_tags=file_interface
# bats test_tags=workflow, panorama
@test "Panorama get_ms_data_files workflow runs sucessfully" {

    # generate input files from template
    run "$SCRIPTS_DIR"/venv/bin/add_api_key \
        -o "$DIR"/cromwell/inputs/panorama_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/panorama_api_key.json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/panorama_inputs.json
    assert_success

    # check if we can run the workflow
    cd $TEST_WDL_DIR
    run womtool validate -i "$DIR"/cromwell/inputs/panorama_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/common/file_interface/get_ms_data_files.wdl
    assert_success

    # clean up cromwell dir
    previous_workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/panorama_"$TEST_NAME".json)
    if [[ -d "$previous_workflow_root" ]] ; then
        rm -rf "$previous_workflow_root"
    fi

    # run workflow
    cd "$DIR"/cromwell
    run cromwell run -o options/common.json --imports "$TEST_WDL_DIR"/common.zip \
        -m metadata/panorama_"$TEST_NAME".json --inputs "$DIR"/cromwell/inputs/panorama_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/common/file_interface/get_ms_data_files.wdl

    echo -e "$output" > "$DIR"/cromwell/cromwell-workflow-logs/panorama_"$TEST_NAME".log
    assert_success
}

# bats test_tags=check, panorama
@test "Check list_panorama_wide_files output" {
    task_name='list_panorama_wide_files'
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/panorama_"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/$task_name"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        -e "$target_dir"/file_list.txt \
        -e "$target_dir"/url_list.txt \
        "$workflow_root/call-$task_name/execution"
    echo -e "${BATS_TEST_NAME}\n${BATS_RUN_COMMAND}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

# bats test_tags=check, panorama
@test "Check list_panorama_narrow_files output" {
    task_name='list_panorama_narrow_files'
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/panorama_"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/$task_name"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        -e "$target_dir"/file_list.txt \
        -e "$target_dir"/url_list.txt \
        "$workflow_root/call-$task_name/execution"
    echo -e "${BATS_TEST_NAME}\n${BATS_RUN_COMMAND}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

# bats file_tags=file_interface
# bats test_tags=workflow, local
@test "Failing get_ms_data_files workflow fails" {

    # generate input files from template
    run "$SCRIPTS_DIR"/venv/bin/generate_cromwell_inputs \
        -o "$DIR"/cromwell/inputs/failing_local_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/local_inputs_template.json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/failing_local_inputs.json
    assert_success

    # check if we can run the workflow
    cd $TEST_WDL_DIR
    run womtool validate -i "$DIR"/cromwell/inputs/failing_local_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/common/file_interface/get_ms_data_files.wdl
    assert_success

    # clean up cromwell dir
    previous_workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/failing_local_"$TEST_NAME".json)
    if [[ -d "$previous_workflow_root" ]] ; then
        rm -rf "$previous_workflow_root"
    fi

    # run workflow
    cd "$DIR"/cromwell
    run cromwell run -o options/common.json --imports "$TEST_WDL_DIR"/common.zip \
        -m metadata/failing_local_"$TEST_NAME".json --inputs "$DIR"/cromwell/inputs/failing_local_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/common/file_interface/get_ms_data_files.wdl

    echo -e "$output" > "$DIR"/cromwell/cromwell-workflow-logs/failing_local_"$TEST_NAME".log
    assert_failure
}

# bats file_tags=file_interface
# bats test_tags=workflow, local
@test "Local no narrow get_ms_data_files workflow runs sucessfully" {

    # generate input files from template
    run "$SCRIPTS_DIR"/venv/bin/generate_cromwell_inputs \
        -o "$DIR"/cromwell/inputs/local_no_narrow_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/local_no_narrow_inputs_template.json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/local_no_narrow_inputs.json
    assert_success

    # check if we can run the workflow
    cd $TEST_WDL_DIR
    run womtool validate -i "$DIR"/cromwell/inputs/local_no_narrow_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/common/file_interface/get_ms_data_files.wdl
    assert_success

    # clean up cromwell dir
    previous_workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/local_no_narrow_"$TEST_NAME".json)
    if [[ -d "$previous_workflow_root" ]] ; then
        rm -rf "$previous_workflow_root"
    fi

    # run workflow
    cd "$DIR"/cromwell
    run cromwell run -o options/common.json --imports "$TEST_WDL_DIR"/common.zip \
        -m metadata/local_no_narrow_"$TEST_NAME".json --inputs "$DIR"/cromwell/inputs/local_no_narrow_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/common/file_interface/get_ms_data_files.wdl

    echo -e "$output" > "$DIR"/cromwell/cromwell-workflow-logs/local_no_narrow_"$TEST_NAME".log
    assert_success
}

# bats file_tags=file_interface
# bats test_tags=workflow, pdc
@test "PDC get_ms_data_files workflow runs sucessfully" {

    # check if we can run the workflow
    cd $TEST_WDL_DIR
    run womtool validate -i "${TEST_WDL_DIR}/test_get_ms_data_files/pdc_inputs.json" \
        "$TEST_WDL_DIR"/common/file_interface/get_ms_data_files.wdl
    assert_success

    # clean up cromwell dir
    previous_workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/pdc_"$TEST_NAME".json)
    if [[ -d "$previous_workflow_root" ]] ; then
        rm -rf "$previous_workflow_root"
    fi

    # run workflow
    cd "$DIR"/cromwell
    run cromwell run -o options/common.json --imports "$TEST_WDL_DIR"/common.zip \
        -m metadata/pdc_"$TEST_NAME".json --inputs "${TEST_WDL_DIR}/test_get_ms_data_files/pdc_inputs.json" \
        "$TEST_WDL_DIR"/common/file_interface/get_ms_data_files.wdl

    echo -e "$output" > "$DIR"/cromwell/cromwell-workflow-logs/pdc_"$TEST_NAME".log
    assert_success
}

