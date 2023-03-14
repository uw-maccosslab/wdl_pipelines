
setup () {
    load 'test_helper/common_setup'
    _common_setup
    TEST_NAME='test_EncyclopeDIA_pipeline'
    COMPARISON_LOG_NAME="$DIR/logs/${TEST_NAME}_file_comparison.log"
}

setup_file () {
    setup
    _copy_common
    _copy_pipelines
    rm -rf "$COMPARISON_LOG_NAME"
}

# bats file_tags=proteowizard
# bats test_tags=workflow, panoramaweb
@test "Local EncyclopeDIA pipeline runs sucessfully" {

    # generate input files from template
    run "$SCRIPTS_DIR"/venv/bin/add_api_key \
        --ofname "$DIR"/cromwell/inputs/panorama_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/panorama_api_key.json \
        "$TEST_WDL_DIR"/pipelines/DIA_Panorama_EncyclopeDIA/panorama_inputs.json
    assert_success

    # check if we can run the workflow
    cd $TEST_WDL_DIR
    run womtool validate -i "$DIR"/cromwell/inputs/panorama_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/pipelines/DIA_Panorama_EncyclopeDIA/workflow.wdl
    assert_success

    # # clean up cromwell dir
    previous_workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/panorama_"$TEST_NAME".json)
    if [[ -d "$previous_workflow_root" ]] ; then
        rm -rf "$previous_workflow_root"
    fi

    # # run workflow
    cd "$DIR"/cromwell
    run cromwell run -o options/common.json --imports "$TEST_WDL_DIR"/common.zip \
        -m metadata/panorama_"$TEST_NAME".json --inputs "$DIR"/cromwell/inputs/panorama_"$TEST_NAME".json \
        "$TEST_WDL_DIR"/pipelines/DIA_Panorama_EncyclopeDIA/workflow.wdl

    echo -e "$output" > "$DIR"/cromwell/cromwell-workflow-logs/"$TEST_NAME".log
    assert_success
}

# bats test_tags=check, full
# @test "Check full export_precursor_report output" {
#     task_name='export_precursor_report'
#     workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/panorama_"$TEST_NAME".json)
#     target_dir="${PROJECT_ROOT}/test/data/"$TEST_NAME"/$task_name"
#     run "$SCRIPTS_DIR"/venv/bin/compare_cromwell_output -e "$target_dir"/rc \
#         --addTsv "$target_dir"/precursor_quality.tsv \
#         "$workflow_root/call-$task_name/execution"
#     echo -e "${BATS_TEST_NAME}\n${BATS_RUN_COMMAND}\n${output}\n" >> $COMPARISON_LOG_NAME
#     [ "$status" -eq 0 ]
# }

