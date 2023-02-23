version 1.0

import "common/proteowizard/proteowizard.wdl" as pwiz

workflow test_msconvert_tasks {
    input {
        File overlapping_window_test_mzml
        File non_overlapping_test_mzml
    }

    # generate_msconvert_config tests
    call pwiz.generate_msconvert_config as test_generate_overlapping_config {
        input:
            mzml_file = overlapping_window_test_mzml
    }
    call pwiz.generate_msconvert_config as test_generate_non_overlapping_config {
        input:
            mzml_file = non_overlapping_test_mzml
    }
}

