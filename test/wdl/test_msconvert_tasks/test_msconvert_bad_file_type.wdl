version 1.0

import "common/proteowizard/proteowizard.wdl" as pwiz

workflow test_msconvert_bad_file_type {
    input {
        File test_thermo_raw_file
    }

    # test different msconvert file formats
    Array[String] msconvert_args = ["--mzML", "--simAsSpectra", "--filter 'peakPicking vendor msLevel=1-2'"]
    call pwiz.msconvert as test_sciex {
        input:
            raw_file = test_thermo_raw_file,
            msconvert_args = msconvert_args,
            retries = 1,
            file_type = "dummy"
    }
}

