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
        docker: "mauraisa/wdl_array_tools:0.3"
    }

    meta {
        author: "Aaron Maurais"
        email: "mauraisa@uw.edu"
        description: "Reutrn true if any elements in rhs and lhs are the same."
    }
}

