version 1.0


task generate_msconvert_config {
    input {
      File mzml_file
    }

  command {
    generateMsconvertConfig "${mzml_file}"
  }

  runtime {
    docker: "mauraisa/generate_msconvert_config:latest"
  }

  output {
    File msconvert_config = "msconvert_params.txt"
  }
}


task msconvert {
    input {
        File raw_file
        File? config_file
        Array[String]? msconvert_args
        Int retries = 3
    }

    command <<<
        declare -i RETRIES=~{retries}
        FAILED_PATTERN='starting debugger...'
        FILE_NAME='msconvert_error.txt'

        # build msconvert argv
        if [ ! -z "~{config_file}" ] ; then
            ARGV="-c ~{config_file}"
        elif [ ! -z "~{sep=' ' msconvert_args}" ] ; then
            ARGV="~{sep=' ' msconvert_args}"
        else
            echo "MSCONVERT_FAILED" > ./converted_file_name.txt
            echo -e "Missing config_file or msconvert_args!\nExiting..."
            exit 1
        fi

        echo "wine msconvert --singleThreaded $ARGV ~{raw_file}" > msconvert_command.sh

        for ((i=0; i < RETRIES ; i++)) ; do
            printf "\nTry number: %s of %s\n" $((i + 1)) $RETRIES
            rm -fv $FILE_NAME msconvert_output.txt
            echo "THE msconvert COMMAND WAS ..."
            cat msconvert_command.sh

            echo 'Starting msconvert...'
            bash msconvert_command.sh > >(tee -a msconvert_output.txt) 2> >(tee -a "$FILE_NAME" >&2)
            rc=$?
            echo "Return code was $rc"

            if [ $rc -eq 0 ] ; then
                echo 'msconvert was sucessful!'
                grep 'writing output file' ./msconvert_output.txt |sed 's/writing output file: \.\\//' > converted_file_name.txt
                exit 0
            fi

            echo "msconvert failed! Trying again..."
        done

        echo "MSCONVERT_FAILED" > ./converted_file_name.txt
        echo 'Exiting...'
        exit 1
    >>>

    runtime {
        docker: "proteowizard/pwiz-skyline-i-agree-to-the-vendor-licenses:latest"
    }

    output {
        String converted_file_name = read_string("./converted_file_name.txt")
        File converted_file = converted_file_name
    }
}


task skyline_import_search {
    input {
        File skyline_template_zip
        File background_proteome_fasta
        File chr_lib
        Array[File] mzml_files
        String? skyline_share_zip_type = "minimal"
        String? skyline_output_name
        Int files_to_import_at_once = 10
        Int import_retries = 3
    }

    String? local_skyline_output_name = if defined(skyline_output_name)
        then skyline_output_name
        else basename(skyline_template_zip, ".sky.zip") + "_out"
    String skyline_template_basename = basename(skyline_template_zip, ".sky.zip")

    command <<<
        declare -i RETRIES=~{import_retries}

        # unzip skyline template file
        cp -v "~{skyline_template_zip}" "~{skyline_template_basename}.sky.zip"
        unzip "~{skyline_template_basename}.sky.zip"

        # link blib to execution directory
        lib_basename=$(basename '~{chr_lib}')
        ln -sv '~{chr_lib}' "$lib_basename"

        # create array of import commands
        files=( ~{sep=' ' mzml_files} )
        echo -e "\nImporting ${#files[@]} files in total."
        file_count=0
        not_done=true
        add_commands=()
        while $not_done; do
            add_command=""
            for ((i=0; i < ~{files_to_import_at_once}; i++)); do
                if [[ $file_count -ge "${#files[@]}" ]] ; then
                    not_done=false
                    break
                fi
                add_command="${add_command} --import-file=${files[$file_count]}"
                (( file_count++ ))
            done
            if [[ "$add_command" != "" ]] ; then
                add_commands+=("$add_command")
            fi
        done

        # add library and fasta file to skyline template and save to new file
        wine SkylineCmd --in="~{skyline_template_basename}.sky" --log-file=skyline_add_library.log \
            --import-fasta="~{background_proteome_fasta}" --add-library-path="$lib_basename" \
            --out="~{local_skyline_output_name}.sky" \
            --save

        # run skyline import in groups of n files
        # Importing in groups is necissary because sometimes there are random errors when accessing
        # files on the network file system inside of wine. By importing in groups we can avoid having
        # to start over at the begining if one of these intermittent errors occures.
        files_imported=0
        for c in "${add_commands[@]}" ; do

            # write import command to temporary file
            # This is necissary because wine is stupid and dosen't expand shell varaibles.
            echo "wine SkylineCmd --in=\"~{local_skyline_output_name}.sky\" \
                      --log-file=skyline_import_files.log \
                      $c --save" > import_command.sh

            # print progress
            files_in_group=$(cat import_command.sh |grep -o '\.mzML\s'|wc -l)
            (( files_imported += files_in_group ))
            echo -e "\nImporting ${files_imported} of ${#files[@]} files..."
            echo "The SkylineCmd import command was..."
            cat import_command.sh

            # Import file group with retries if there is an error
            import_sucessful=false
            for ((i=0; i < RETRIES; i++)); do
                printf "\nTry number: %s of %s\n" $((i + 1)) $RETRIES
                bash import_command.sh
                if [[ $? -eq 0 ]] ; then
                    echo "Import was sucessful!"
                    import_sucessful=true
                    break
                fi
                echo "Import failed!"
            done
            if ! $import_sucessful ; then
                exit 1
            fi
        done

        # create skyline zip file
        wine SkylineCmd --in="~{local_skyline_output_name}.sky" --log-file=skyline_share_zip.log \
            --share-zip="~{local_skyline_output_name}.sky.zip" --share-type="~{skyline_share_zip_type}"
    >>>

    runtime {
        docker: "proteowizard/pwiz-skyline-i-agree-to-the-vendor-licenses:latest"
    }

    output {
        File skyline_output = "${local_skyline_output_name}.sky.zip"
    }

    parameter_meta {
        skyline_output_name: "The basename of the skyline output file."
    }

    meta {
        author: "Aaron Maurais"
        email: "mauraisa@uw.edu"
        description: "Import DIA search into Skyline."
    }
}


task skyline_annotate_document {
    input {
      File skyline_input_zip
      File annotation_csv
      String? skyline_share_zip_type = "minimal"
      String? skyline_output_name
    }

    String? local_skyline_output_name = if defined(skyline_output_name)
        then skyline_output_name
        else basename(skyline_input_zip, ".sky.zip") + "_annotated"
    String skyline_input_basename=basename(skyline_input_zip, ".sky.zip")

  command {
    # unzip skyline input file
    cp -v "${skyline_input_zip}" "${skyline_input_basename}.sky.zip"
    unzip "${skyline_input_basename}.sky.zip"

    # run skyline
    wine SkylineCmd --in="${skyline_input_basename}.sky" \
    --log-file=log.txt \
    --out="${local_skyline_output_name}.sky" \
    --import-annotations="${annotation_csv}" --save \
    --share-zip="${local_skyline_output_name}.sky.zip" --share-type="${skyline_share_zip_type}"
  }

  runtime {
    docker: "proteowizard/pwiz-skyline-i-agree-to-the-vendor-licenses:latest"
  }

  output {
    File log_file = "log.txt"
    File skyline_output = "${local_skyline_output_name}.sky.zip"
  }

  meta {
    author: "Aaron Maurais"
    email: "mauraisa@uw.edu"
    description: "Add annotations csv into skyline file."
  }
}
