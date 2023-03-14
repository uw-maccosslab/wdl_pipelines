version 1.0

import "https://raw.githubusercontent.com/uw-maccosslab/wdl_pipelines/master/wdl/common/pdc.wdl" as pdc
import "https://raw.githubusercontent.com/uw-maccosslab/wdl_pipelines/master/wdl/common/panoramaweb.wdl" as panorama
import "https://raw.githubusercontent.com/uw-maccosslab/wdl_pipelines/master/wdl/common/proteowizard/proteowizard.wdl" as pwiz
import "https://raw.githubusercontent.com/uw-maccosslab/wdl_pipelines/master/wdl/common/utils.wdl" as utils
import "https://raw.githubusercontent.com/uw-maccosslab/wdl_pipelines/master/wdl/common/file_interface/file_interface.wdl" as file_interface

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

    # list local files
    if(file_mode == "local") {
        call file_interface.list_local_files as list_local_wide_files {
            input: path = input_wide_files_folder_uri,
                   extension = input_files_ext,
                   include_regex = input_wide_files_regex
        }
        if(defined(input_narrow_files_folder_uri)) {
            call file_interface.list_local_files as list_local_narrow_files {
                input: path = select_first([input_narrow_files_folder_uri,]),
                       extension = input_files_ext,
                       include_regex = input_narrow_files_regex
            }
        }
    }

    # list and download panorama files
    if(file_mode == "panorama" || file_mode == "panoramaweb") {
        call panorama.list_files as list_panorama_wide_files {
            input: folder_webdav_url = input_wide_files_folder_uri,
                   api_key = panorama_api_key,
                   file_ext = input_files_ext,
                   file_regex = input_wide_files_regex
        }
        scatter (file_webdav_url in select_all([list_panorama_wide_files.url_list,])) {
            call panorama.download_file as download_panorama_wide_files {
                input: file_url = file_webdav_url,
                       api_key = panorama_api_key
            }
        }
        if(defined(input_narrow_files_folder_uri)) {
            call panorama.list_files as list_panorama_narrow_files {
                input: folder_webdav_url = select_first([input_narrow_files_folder_uri,]),
                       api_key = panorama_api_key,
                       file_ext = input_files_ext,
                       file_regex = input_narrow_files_regex
            }
            
            scatter (file_webdav_url in select_all([list_panorama_narrow_files.url_list,])) {
                call panorama.download_file as download_panorama_narrow_files {
                    input: file_url = file_webdav_url,
                           api_key = panorama_api_key
                }
            }
        }
    }
    
    # list and download pdc files
    # download pdc study metadata

    # run msconvert on the files that were downloaded
    if(input_files_ext == "raw") {

        # generate msconvert config file if necissary
        if(!defined(msconvert_config_uri)) {
            Array[String] msconvert_args = ["--mzML", "--mz64", "--inten64", "--simAsSpectra",
              "--filter 'peakPicking vendor msLevel=1-2'", "--filter 'scanNumber [1000,2000]'"]
            call pwiz.msconvert as msconvert_subset {
              input: raw_file = select_first([list_local_wide_files.files,
                                              download_panorama_wide_files.downloaded_file])[0],
                     msconvert_args = msconvert_args
            }
            call pwiz.generate_msconvert_config {
              input: mzml_file = msconvert_subset.converted_file
            }
        }

        # convert wide window files
        scatter (raw_file in select_first([list_local_wide_files.files,
                                           download_panorama_wide_files.downloaded_file])) {
            call pwiz.msconvert as msconvert_wide {
                input: raw_file = raw_file,
                       config_file = generate_msconvert_config.msconvert_config
            }
        }

        # convert narrow window files if necissary
        if(defined(input_narrow_files_folder_uri)) {
            scatter (raw_file in select_first([list_local_narrow_files.files,
                                               download_panorama_narrow_files.downloaded_file])) {
                call pwiz.msconvert as msconvert_narrow {
                    input: raw_file = raw_file,
                           config_file = generate_msconvert_config.msconvert_config
                }
            }
        }
    }

    output {
        Array[File]? mzml_narrow_files = select_first([msconvert_narrow.converted_file, list_local_narrow_files.files])
        Array[File] mzml_wide_files = select_first([msconvert_wide.converted_file, list_local_wide_files.files,])
        # File? metadata_csv
    }
}
