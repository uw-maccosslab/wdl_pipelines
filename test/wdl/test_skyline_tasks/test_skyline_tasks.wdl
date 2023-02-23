version 1.0

import "common/proteowizard/proteowizard.wdl" as pwiz

workflow test_skyline_tasks {
    input {
        File skyline_template
        File mzml_directory
        File blib_library
        File precursor_quality_report_tempalte
        File background_fasta
    }
    
    call list_files as list_wide_mzml_files {
        input: path = mzml_directory
    }

    # import results to skyline
    call pwiz.skyline_add_library {
        input: skyline_template_zip = skyline_template,
               background_proteome_fasta = background_fasta,
               library = blib_library,
               skyline_share_zip_type = "complete"
    }
    call pwiz.skyline_import_results {
        input: skyline_zip = skyline_add_library.skyline_output,
               mzml_files = list_wide_mzml_files.files,
               skyline_share_zip_type = "complete"
    }

    call pwiz.skyline_export_report as export_precursor_report {
        input: skyline_zip = skyline_import_results.skyline_output,
               report_template = precursor_quality_report_tempalte
    }
}

task list_files {
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

