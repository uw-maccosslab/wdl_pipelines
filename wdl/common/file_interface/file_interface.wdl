version 1.0

import "https://raw.githubusercontent.com/uw-maccosslab/wdl_pipelines/master/wdl/common/panoramaweb.wdl" as panorama

workflow get_file {
    input {
        String path
        String file_mode
        String? panorama_api_key
    }

    if (file_mode == "panorama"){
        call panorama.download_file as download_panorama_file {
            input: file_url = path,
                   api_key = panorama_api_key
        }
    }
    if (file_mode == "local") {
        File local_file = path
    }

    output {
        File file = select_first([download_panorama_file.downloaded_file,
                                  local_file])
    }
}

task list_local_files {
    input {
        File path
        String? include_regex
        String? exclude_regex
        String? extension
        Boolean allow_empty = false
    }
    
    String list_command = "ls ${path}" + if defined(extension) then "/*.${extension}" else ""
    
    command <<<
        if ! [[ -d ~{path} ]] ; then
            echo "~{path} is not a directory!"
            exit 1
        fi

        ~{list_command} ~{"| egrep '" + include_regex + "'"} ~{"| egrep -v '" + exclude_regex + "'"} > files.txt

        if [[ $(wc -l <files.txt) -eq 0 ]] ; then
            if ~{allow_empty} ; then
                echo "No files found!" >&2
                exit 1
            fi
        else
            cat files.txt |xargs -n 1 realpath |xargs -I{} ln -sv "{}" .
            mv -v files.txt ls.out.txt
            cat ls.out.txt| xargs -n 1 basename > files.txt
        fi
    >>>
    output {
        Array[File] files = read_lines("files.txt")
    }

    parameter_meta {
        path: "The directory to list."
        include_regex: "Only include files matching this regex."
        exclude_regex: "Exclude files matching this regex."
        extension: "Only include files with this extension"
        allow_empty: "Fail if no files were found?"
    }
    meta {
        author: "Aaron Maurais"
        email: "mauraisa@uw.edu"
        description: "List files in directory on local machine."
    }
}

