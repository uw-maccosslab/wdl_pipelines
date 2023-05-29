version 1.0

import "common/proteowizard/proteowizard.wdl" as pwiz

workflow test_msconvert_tasks {
    input {
        File overlapping_window_test_mzml
        File non_overlapping_test_mzml
        File test_thermo_raw_file
        File test_sciex_wiff_zip_file
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

    # test different msconvert file formats
    Array[String] msconvert_args = ["--mzML", "--simAsSpectra", "--filter 'peakPicking vendor msLevel=1-2'"]
    call pwiz.msconvert as test_thermo {
        input:
            raw_file = test_thermo_raw_file,
            msconvert_args=msconvert_args,
            retries=1
    }
    call pwiz.msconvert as test_sciex {
        input:
            raw_file = test_sciex_wiff_zip_file,
            msconvert_args = msconvert_args,
            retries = 1,
            file_type = "sciex"
    }
}

