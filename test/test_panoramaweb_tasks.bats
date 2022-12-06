
setup () {
    load 'test_helper/common_setup'
    _common_setup
    rm -rf $DIR/cromwell/cromwell-executions/test_panorama_list_files/*
}

@test "test_panorama_list_files workflow has valid syntax" {
    run womtool validate "$TEST_WDL_DIRNAME"/test_panoramaweb_tasks.wdl
    echo -e "$output" > "$DIR"/logs/validate_test_panoramaweb_tasks.log
    if ! [[ $status -eq 0 ]] ; then
        echo -e "\nCommand: ${BATS_RUN_COMMAND}"
        echo -e "\nCommand output:\n\n${output}\n" >&2
    fi
    check_state $status
}

@test "test_panorama_list_files workflow runs sucessfully" {
    cd "$DIR"/cromwell
    run cromwell run -m metadata/test_panoramaweb_tasks.json -o options/common.json --imports "$TEST_WDL_DIRNAME"/common.zip "$TEST_WDL_DIRNAME"/test_panoramaweb_tasks.wdl
    echo -e "$output" > "$DIR"/cromwell/cromwell-workflow-logs/test_panoramaweb_tasks.log
    assert_success
}

# workflow_root=$(get_workflow_root "$DIR"/cromwell/metadata/test_panoramaweb_tasks.json)
# echo "Workflow root is: $workflow_root"


