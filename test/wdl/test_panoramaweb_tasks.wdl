version 1.0

import "common/panoramaweb.wdl" as panorama

workflow test_panorama_list_files {
    input {
        String base_folder_url = "https://panoramaweb.org/_webdav/Panorama%20Public/2019/MacCoss%20-%20matched%20matrix%20cal%20curves/@files/"
    }

    call panorama.list_files as test_file_ext {
        input: 
            folder_webdav_url = base_folder_url,
            file_ext = "sky.zip"
    }
}

