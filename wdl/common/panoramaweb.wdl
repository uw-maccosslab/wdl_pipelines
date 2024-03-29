version 1.0


task list_files {
    input {
        String folder_webdav_url
        String? api_key
        String? file_ext
        String file_regex = ""
        Boolean allow_empty = false
        Int? limit
    }

    String api_key_arg = if defined(api_key) then "-k '" + api_key + "'" else ""
    String file_ext_arg = if defined(file_ext) then "-e " + file_ext else ""
    Int n_files = select_first([limit, -1])

    command {
        java -jar /code/PanoramaClient.jar \
             -l \
             ${api_key_arg} \
             ${file_ext_arg} \
             -w "${folder_webdav_url}" \
             -o all_files.txt

        if [[ ${n_files} -ge 0 ]] ; then
            echo 'Limiting number of files...'
            egrep '${file_regex}' all_files.txt | head -n ${n_files} > file_list.txt
        else
            echo 'Not lmiting number of files...'
            egrep '${file_regex}' all_files.txt > file_list.txt
        fi
        sed 's#^#${folder_webdav_url}/#' file_list.txt > url_list.txt
        if ! [ -s file_list.txt ] ; then
            echo "No files match criteria!"
            if ! ${allow_empty} ; then
                exit 1
            fi
        fi
    }

    runtime {
        docker: "proteowizard/panorama-client-java:latest"
    }

    output {
        File file_list = "file_list.txt"
        File url_list = "url_list.txt"
    }

    parameter_meta {
        folder_webdav_url: "Folder on Panorama Server where files are located."
        api_key: "Panorama Server API key"
        file_ext: "(optional) File extension"
        file_regex: "(optional) Regex to filter files"
        allow_empty: "(optional) Should empty file lists be allowed? (default = false)"
        limit: "(optional) Limit file list to the first n files."
    }

    meta {
        author: "Aaron Maurais"
        email: "mauraisa@uw.edu"
        description: "List files in folder on Panorama Server"
    }
}


task download_file {
    input {
      String file_url
      String? api_key
    }

    command <<<
        java -jar /code/PanoramaClient.jar -d -w '~{file_url}' ~{"-k '" + api_key + "'"}
    >>>

    runtime {
        docker: "proteowizard/panorama-client-java:1.3"
    }

    output {
        File downloaded_file = basename("${file_url}")
        File task_log = stdout()
    }
}


task upload_file {
    input {
      String dest
      String api_key
      File file_to_be_uploaded
      Int retries = 3
    }

    command {
      declare -i RETRIES=${retries}

      for ((i=0; i < RETRIES ; i++)) ; do
        java -jar /code/PanoramaClient.jar \
          -u \
          -w "${dest}" \
          -f "${file_to_be_uploaded}" \
          -k "${api_key}"
        rc=$?

        if [ $rc -eq 0 ] ; then
          exit 0;
        fi
      done
      exit 1
    }

    runtime {
        docker: "proteowizard/panorama-client-java:1.3"
    }

    output {
        File task_log = stdout()
    }

    parameter_meta {
        dest: "WebDav url of destination directory on Panorama."
        api_key: "Panorama Server API key"
    }
}


task import_skyline {
    input {
      String panorama_folder
      String api_key
      File skyline_zip_file_to_upload
      Int retries = 5
    }

  command {
    declare -i RETRIES=${retries}

    for ((i=0; i < RETRIES ; i++)) ; do
      java -jar /code/PanoramaClient.jar \
        -i \
        -p "${panorama_folder}" \
        -k "${api_key}" \
        -s "${skyline_zip_file_to_upload}"
      rc=$?

      if [ $rc -eq 0 ] ; then
        exit 0;
      fi
    done
    exit 1
  }

  runtime {
    docker: "mauraisa/panorama-client-java:1.4"
  }

  output {
    File task_log = stdout()
  }
}

