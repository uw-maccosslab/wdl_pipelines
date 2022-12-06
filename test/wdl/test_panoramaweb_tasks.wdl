version 1.0

import "common/panoramaweb.wdl" as panorama

workflow test_panorama_list_files {
    input {
        String base_folder_url = "https://panoramaweb.org/_webdav/Panorama%20Public/2019/MacCoss%20-%20matched%20matrix%20cal%20curves/@files/"
        String raw_files_folder = "RawFiles/csf_curves"
    }

    call panorama.list_files as test_file_ext {
        input: 
            folder_webdav_url = base_folder_url,
            file_ext = "sky.zip"
    }

    call panorama.list_files as test_list_files_with_limit {
        input:
            folder_webdav_url = base_folder_url + raw_files_folder,
            limit = 5
    }

    call panorama.list_files as test_list_files_without_limit {
        input:
            folder_webdav_url = base_folder_url + raw_files_folder,
            file_ext = "raw"
    }

    # call panorama.list_files as test_regex_filter_without_limit {

    # }

    # call panorama.list_files as test_regex_filter_with_limit {
    #     input:
    #         folder_webdav_url = base_folder_url + 
    # }

}

