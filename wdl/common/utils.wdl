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
    String header_filter = if header then "tail -n +2| " else ""
    String command = header_filter + grep_command + flags

    command {
        ofname=$(echo "${file}"|xargs basename| sed 's/^/subset_/')
        echo "$ofname" > ofname.txt
        echo "${sep=' ' subset}" | xargs -n 1 echo > filter.txt
        if ${header} ; then
            echo 'Printing header...'
            head -n 1 '${file}' > "$ofname"
        fi
        cat '${file}'| ${command} -f filter.txt >> "$ofname"
    }
    runtime {
        docker: "mauraisa/wdl_array_tools:latest"
    }
    output {
        File subset_file = read_string("ofname.txt")
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

