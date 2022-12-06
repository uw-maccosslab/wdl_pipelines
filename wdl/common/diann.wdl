version 1.0


task get_file_mz_ranges {
    input {
        File mzml_file
    }

    command {
        getFileRanges -f json ${mzml_file} > mz_ranges.json
    }

    runtime {
        docker: "mauraisa/generate_msconvert_config:1.2"
    }

    output {
        File file_mz_ranges = "mz_ranges.json"
    }
}


task build_blib_library {
    input {
        File speclib
        File precursor_tsv
    }

    command {
        ln -sv '${speclib}' ./report.tsv.speclib
        ln -sv '${precursor_tsv}' ./report.tsv

        wine BlibBuild.exe report.tsv.speclib lib_redundant.blib
        wine BlibFilter.exe lib_redundant.blib lib.blib
    }

    runtime {
        docker: "proteowizard/pwiz-skyline-i-agree-to-the-vendor-licenses:latest"
    }

    output {
        File blib = "lib.blib"
    }

    meta {
        description: "Build a .blib library from a DiaNN search."
    }
    parameter_meta {
        speclib: "DiaNN .speclib file"
        precursor_tsv: "DiaNN precursor report .tsv file."
    }
}


task diann_search {
    input {
      File fasta_file
      Array[File] mzml_files
      File? spectral_library
      Float qvalue = 0.01
      String cut = "'K*,R*,!*P'"
      Int max_missed_cleavages = 1
      Int max_var_mods = 1
      Float? min_precursor_mz
      Float? max_precursor_mz
      Int? min_precursor_charge = 2
      Int? max_precursor_charge = 3
      Float? min_fragment_mz
      Float? max_fragment_mz
      Array[String]? variable_modifications = ["'UniMod:35,15.994915,M'"]
      String? monitor_mod
      Int? threads
    }

    String other_args = if !defined(spectral_library) then "--predictor --fasta-search" else ""
    String var_mod = if defined(variable_modifications) then "--var-mod " else ""
    String num_threads = if defined(threads) then "--threads " + threads else ""

    Boolean range_specified = defined(min_precursor_mz) || defined(max_precursor_mz) || defined(min_fragment_mz) || defined(max_fragment_mz)
    String min_pr_charge = if range_specified then "--min-pr-charge " + min_precursor_charge else ""
    String max_pr_charge = if range_specified then "--max-pr-charge " + max_precursor_charge else ""
    String min_pr_mz = if defined(min_precursor_mz) then "--min-pr-mz " + min_precursor_mz else ""
    String max_pr_mz = if defined(max_precursor_mz) then "--max-pr-mz " + max_precursor_mz else ""
    String min_fr_mz = if defined(min_fragment_mz) then "--min-fr-mz " + min_fragment_mz else ""
    String max_fr_mz = if defined(max_fragment_mz) then "--max-fr-mz " + max_fragment_mz else ""

    command {
        diann --f "${sep='" --f "' mzml_files}" \
        ${num_threads} \
        --verbose 1 \
        --fasta "${fasta_file}" \
        --lib "${spectral_library}" \
        --unimod4 \
        --qvalue ${qvalue} \
        --cut ${cut} \
        --missed-cleavages ${max_missed_cleavages} \
        ${var_mod} ${sep=' --var-mod' variable_modifications} \
        --var-mods ${max_var_mods} \
        --reanalyse --smart-profiling \
        ${min_pr_charge} ${max_pr_charge} \
        ${min_pr_mz} ${max_pr_mz} ${min_fr_mz} ${max_fr_mz} \
        ${other_args} && \
        mv -v lib.tsv.speclib report.tsv.speclib
    }

    runtime {
        docker: "mauraisa/diann:1.8"
    }

    output {
        File speclib_file="report.tsv.speclib"
        File precursor_tsv_file="report.tsv"
    }
}

