
task download_study_metadata {
    input {
      String study_id
      Int? limit
      String? api_url
    }

    String file_limit = if(defined(limit)) then "-n " + limit else ""
    String url = if defined(api_url) then "--baseUrl " + api_url else ""

  command <<<

    # an awk script to select only the 3 columns needed from the study metadata
    AWK_SCRIPT='
      NR == 1 {
        for (i=1; i <= NF; i++){
          cols[$i] = i
        }
      }
      NR > 1 {
        printf "%s\t%s\t%s\n", $cols["url"], $cols["md5sum"], $cols["file_name"]
      }'

    # download metadata
    PDC_client metadata ~{url} ~{file_limit} -a -f tsv '~{study_id}'

    # parse metadata file
    awk -F '\t' "$AWK_SCRIPT" study_metadata.tsv > files.tsv
  >>>

  runtime {
    docker: "mauraisa/pdc_client:latest"
  }

  output {
    File metadata_file = "files.tsv"
    File file_annotations = "study_metadata_annotations.csv"
  }
  meta {
    author: "Aaron Maurais"
    email: "mauraisa@uw.edu"
    description: "Download metadata for a PDC study."
  }
}


task lookup_study_id {
    input {
      String study_id
      String? api_url
    }

    String url = if defined(api_url) then "--baseUrl " + api_url else ""

  command {
    PDC_client PDCStudyID ${url} ${study_id} > pdc_study_id.txt
  }

  runtime {
    docker: "mauraisa/pdc_client:latest"
  }

  output {
    String pdc_study_id = read_string("./pdc_study_id.txt")
  }
}


task download_file {
    input {
      String file_url
      String md5_sum
      String file_name
    }

  command {
    PDC_client file --force --noBackup \
      --md5sum "${md5_sum}" \
      --ofname "${file_name}" \
      "${file_url}"
  }

  runtime {
    docker: "mauraisa/pdc_client:latest"
  }

  output {
    File downloaded_file = file_name
  }
  meta {
    author: "Aaron Maurais"
    email: "mauraisa@uw.edu"
    description: "Download file from PDC"
  }
}

