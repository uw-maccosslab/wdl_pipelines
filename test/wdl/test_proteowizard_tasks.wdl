version 1.0

import "common/proteowizard/proteowizard.wdl" as pwiz

workflow test_panorama_list_files {
    input {
        File overlaping_window_test_mzml
        File non_overlapint_test_mzml
    }

    call pwiz.generate_msconvert_config as generate_overlaping_config {
        input:
            mzml_file = overlaping_window_test_mzml
    }
}

