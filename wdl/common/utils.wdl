version 1.0


task arrays_overlap {
    input {
        Array[Array[String]] arrays
    }

    command <<<
        wdl_array_tools arrays_overlap -i ~{write_json(arrays)}

        if [[ $? -eq 1 ]] ; then
            echo "There is overlap!"
            exit 1
        else
            echo "There is no overalp!"
            echo 'false' > has_overlap.txt
        fi
    >>>

    output {
        Boolean any_overlap = read_boolean("has_overlap.txt")
    }

    runtime {
        docker: "mauraisa/wdl_array_tools:latest"
    }

    meta {
        author: "Aaron Maurais"
        email: "mauraisa@uw.edu"
        description: "Check if any of the elements in arrays are the same."
    }
}


task subset_file {
    input {
        File file
        Array[String] subset
        Boolean header = false
        Boolean fixed = true
        Boolean inversed = false
    }

    String grep_command = if fixed then "fgrep" else "egrep"
    String flags = if inversed then " -v" else ""
    String command = grep_command + flags

    command {
        echo "${sep=' ' subset}" | xargs -n 1 echo > subset_filter.txt
        if [[ ${header} ]] ; then
            head -n 1 '${file}' > subset.tsv
        fi
        ${command} -f subset_filter.txt '${file}' > subset.txt
    }
    runtime {
        docker: "mauraisa/wdl_array_tools:latest"
    }
    output {
        File subset_file = "subset.txt"
    }

    meta {
        author: "Aaron Maurais"
        email: "mauraisa@uw.edu"
        description: "Subset file by patterns that occurs in subset."
    }
    parameter_meta {
        file: "A file containing lines of text"
        subset: "An array of patterns to match in file"
        header: "Is the first line of file a header?"
        fixed: "Should the lines in subset be interpreted as RegEx?"
        inversed: "Inversed match lines in subset?"
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

