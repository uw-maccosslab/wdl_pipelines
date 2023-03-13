
setup () {
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    WDL_DIRNAME="$DIR/../wdl/dev_wdl_pipelines/wdl"
    
    load 'test_helper/common_setup.bash'
    _common_setup
}

@test "DIA_PDC_DiaNN has valid syntax" {
    run womtool validate -i "$WDL_DIRNAME"/DIA_PDC_DiaNN/input_template.json "$WDL_DIRNAME"/DIA_PDC_DiaNN/workflow.wdl
    assert_success
}

@test "DIA_PDC_EncyclopeDIA has valid syntax" {
    run womtool validate -i "$WDL_DIRNAME"/DIA_PDC_EncyclopeDIA/input_template.json "$WDL_DIRNAME"/DIA_PDC_EncyclopeDIA/workflow.wdl
    assert_success
}

@test "DIA_Panorama_DiaNN has valid syntax" {
    run womtool validate -i "$WDL_DIRNAME"/DIA_Panorama_DiaNN/input_template.json "$WDL_DIRNAME"/DIA_Panorama_DiaNN/workflow.wdl
    assert_success
}

@test "DIA_Panorama_EncyclopeDIA has valid syntax" {
    run womtool validate -i "$WDL_DIRNAME"/DIA_Panorama_EncyclopeDIA/input_template.json "$WDL_DIRNAME"/DIA_Panorama_EncyclopeDIA/workflow.wdl
    assert_success
}

@test "Panorama_Msconvert has valid syntax" {
    run womtool validate -i "$WDL_DIRNAME"/Panorama_Msconvert/input_template.json "$WDL_DIRNAME"/Panorama_Msconvert/workflow.wdl
    assert_success
}

