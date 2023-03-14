
setup () {
    load 'test_helper/common_setup'
    _common_setup
    TEST_NAME='test_file_interface_tasks'
    COMPARISON_LOG_NAME="$DIR/logs/${TEST_NAME}_file_comparison.log"
}

setup_file () {
    setup
    _copy_common
    rm -rf "$COMPARISON_LOG_NAME"
}

# bats file_tags=file_interface
# bats test_tags=workflow, local
@test "Local get_file workflow runs sucessfully" {

    # generate input files from template
    run "$SCRIPTS_DIR"/venv/bin/generate_cromwell_inputs \
        -o "$DIR"/cromwell/inputs/local_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/local_file_inputs_template.json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/local_file_inputs.json
    assert_success

    # check if we can run the workflow
    cd $TEST_WDL_DIR
    run womtool validate -i "$DIR"/cromwell/inputs/local_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/common/file_interface/file_interface.wdl
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
        "$TEST_WDL_DIR"/common/file_interface/file_interface.wdl

    echo -e "$output" > "$DIR"/cromwell/cromwell-workflow-logs/"$TEST_NAME".log
    assert_success
}

# bats test_tags=workflow, panorama
@test "Panorama get_file workflow runs sucessfully" {

    # generate input files from template
    run "$SCRIPTS_DIR"/venv/bin/add_api_key \
        -o "$DIR"/cromwell/inputs/panorama_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/panorama_api_key.json \
        "$TEST_WDL_DIR"/"$TEST_NAME"/panorama_file_inputs.json
    assert_success

    # check if we can run the workflow
    cd $TEST_WDL_DIR
    run womtool validate -i "$DIR"/cromwell/inputs/panorama_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/common/file_interface/file_interface.wdl
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
        "$TEST_WDL_DIR"/common/file_interface/file_interface.wdl

    echo -e "$output" > "$DIR"/cromwell/cromwell-workflow-logs/"$TEST_NAME".log
    assert_success
}

# bats test_tags=check, panorama
@test "Check panorama get_file output" {
    task_name='download_panorama_file'
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/panorama_"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/${TEST_NAME}/${task_name}"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        -e "$target_dir"/uniprot_human_jan2021_yeastENO1_subset.fasta \
        "$workflow_root/call-$task_name/execution"
    echo -e "${BATS_TEST_NAME}\n${BATS_RUN_COMMAND}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

# bats test_tags=workflow, panorama
@test "Panorama public get_file workflow runs sucessfully" {

    # check if we can run the workflow
    cd $TEST_WDL_DIR
    run womtool validate -i "$TEST_WDL_DIR"/test_file_interface_tasks/panoramapublic_file_inputs.json \
        "$TEST_WDL_DIR"/common/file_interface/file_interface.wdl
    assert_success

    # clean up cromwell dir
    previous_workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/panoramapublic_"$TEST_NAME".json)
    if [[ -d "$previous_workflow_root" ]] ; then
        rm -rf "$previous_workflow_root"
    fi

    # run workflow
    cd "$DIR"/cromwell
    run cromwell run -o options/common.json --imports "$TEST_WDL_DIR"/common.zip \
        -m metadata/panoramapublic_"$TEST_NAME".json \
        --inputs "$TEST_WDL_DIR"/test_file_interface_tasks/panoramapublic_file_inputs.json \
        "$TEST_WDL_DIR"/common/file_interface/file_interface.wdl

    echo -e "$output" > "$DIR"/cromwell/cromwell-workflow-logs/"$TEST_NAME".log
    assert_success
}

# bats test_tags=check, panorama
@test "Check panorama public get_file output" {
    task_name='download_panorama_file'
    workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/panoramapublic_"$TEST_NAME".json)
    target_dir="${PROJECT_ROOT}/test/data/${TEST_NAME}/${task_name}"
    run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
        -e "$target_dir"/px.xml \
        "$workflow_root/call-$task_name/execution"
    echo -e "${BATS_TEST_NAME}\n${BATS_RUN_COMMAND}\n${output}\n" >> $COMPARISON_LOG_NAME
    [ "$status" -eq 0 ]
}

