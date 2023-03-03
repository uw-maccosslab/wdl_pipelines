version 1.0

import "https://raw.githubusercontent.com/uw-maccosslab/wdl_pipelines/master/wdl/common/pdc.wdl" as pdc
import "https://raw.githubusercontent.com/uw-maccosslab/wdl_pipelines/master/wdl/common/panoramaweb.wdl" as panorama
import "https://raw.githubusercontent.com/uw-maccosslab/wdl_pipelines/master/wdl/common/proteowizard/proteowizard.wdl" as pwiz
import "https://raw.githubusercontent.com/uw-maccosslab/wdl_pipelines/master/wdl/common/utils.wdl" as utils

workflow get_ms_data_files {
    input {
        String file_mode
        String? panorama_api_key
        String? pdc_study_id
        String input_wide_files_folder_uri
        String? input_narrow_files_folder_uri
        String input_narrow_files_regex = ""
        String input_wide_files_regex = ""
        String input_files_ext = "raw"
        String? msconvert_config_uri
    }

    if(file_mode == "local") {
        call list_local_files as list_local_wide_files {
            input: path = input_wide_files_folder_uri,
                   include_regex = input_wide_files_regex
        }
        if(defined(input_narrow_files_folder_uri)) {
            call list_local_files as list_local_narrow_files {
                input: path = select_first([input_narrow_files_folder_uri,]),
                       include_regex = input_narrow_files_regex
            }
        }
    }
    if(file_mode == "panorama" || file_mode == "panoramaweb") {
        call panorama.list_files as list_panorama_wide_files {
            input: folder_webdav_url = input_wide_files_folder_uri,
                   api_key = panorama_api_key,
                   file_ext = input_files_ext,
                   file_regex = input_wide_files_regex
        }
        if(defined(input_narrow_files_folder_uri)) {
            call panorama.list_files as list_panorama_narrow_files {
                input: folder_webdav_url = select_first([input_narrow_files_folder_uri,]),
                       api_key = panorama_api_key,
                       file_ext = input_files_ext,
                       file_regex = input_narrow_files_regex
            }
            
            scatter (mzml_webdav_url in select_all([list_panorama_narrow_files.url_list,])) {
                call panorama.download_file as download_panorama_narrow_files {
                    input: file_url = mzml_webdav_url,
                           api_key = panorama_api_key
                }
            }
        }

    }

    output {
        # Array[File]? mzml_narrow_files = select_first([
        Array[File] mzml_wide_files = select_first([list_local_wide_files.files,])
        # File? metadata_csv
    }
}

task dirname {
    input {
        String path
    }
    command {
        dirname ${path}
    }
    runtime {
        docker: "mauraisa/wdl_array_tools:latest"
    }
    output {
        String dirname = read_string(stdout())
    }
}


task list_local_files {
    input {
        File path
        String? include_regex
        String? exclude_regex
        Boolean recursive = false
    }
    
    String list_command = if recursive then "find ${path} -type f" else "ls ${path}" +
        if defined(include_regex) then "| grep ${include_regex}" else "" +
        if defined(exclude_regex) then "| grep -v ${exclude_regex}" else ""

    command {
        if ! [ -d ${path} ] ; then
            echo "${path} is not a directory!"
            exit 1
        fi

        ${list_command} |sed 's#^#${path}/#' > files.txt
    }
    output {
        Array[File] files = read_lines("files.txt")
    }

    parameter_meta {
        path: "The directory to list."
        include_regex: "Only include files matching this regex."
        exclude_regex: "Exclude files matching this regex."
        recursive: "Recursively list path? default = false"
    }
    meta {
        author: "Aaron Maurais"
        email: "mauraisa@uw.edu"
        description: "List files in directory on local machine."
    }
}

