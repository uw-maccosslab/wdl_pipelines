version 1.0

import "common/utils.wdl" as utils
import "common/file_interface/file_interface.wdl" as file_interface

workflow test_utils_tasks {
    input {
        File subset_file
        File subset_file_with_header
        String dirname_test_url = "https://panoramaweb.org/_webdav/MacCoss/Aaron/cromwell_tests/PDC000414/%40files/reports/peptide_abundance_long.skyr"
        String dirname_test_real_file = "/usr/local/bin/bash"
        String dirname_test_fake_file = "/home/jp2/code/wdl_pipelines/test/this_is_a_fake_file_path.cpp"
    }

    # tests dirname
    call file_interface.dirname as dirname_url_test { input: path = dirname_test_url }
    call file_interface.dirname as dirname_real_file_test { input: path = dirname_test_real_file }
    call file_interface.dirname as dirname_fake_file_test { input: path = dirname_test_fake_file }

    # test subset_file
    call utils.subset_file as subset_fixed {
        input: file=subset_file,
               subset=["20180910_18Ocurves_csf_0ug_003.raw", "20180910_18Ocurves_csf_0ug_022.raw",
                       "20180910_18Ocurves_csf_0ug_034.raw", "20180910_18Ocurves_csf_1ug_012.raw",
                       "20180910_18Ocurves_csf_1ug_032.raw", "20180910_18Ocurves_csf_1ug_044.raw"]
    }
    call utils.subset_file as subset_inversed {
        input: file=subset_file,
               subset=["library"],
               fixed=false,
               inversed=true
    }
    call utils.subset_file as subset_regex {
        input: file=subset_file,
               subset=["library_[0-9]00-[0-9]00_0[0-7]{2}\.raw"],
               fixed=false
    }
    call utils.subset_file as subset_with_header {
        input: file=subset_file_with_header,
               subset=["library"],
               fixed=true,
               header=true
    }
}

