version 1.0


task search_file {
    input {
      File input_file
      File fasta
      File library_elib
      String encyclopedia_version
      String memory = "12g"
      Int numberOfThreadsUsed = 2
      String? encyclopedia_percolator_version
      String? encyclopedia_percolator_trainingsetsize
      String? out_report_file
      String? acquisition
      String? enzyme
      Int? expectedPeakWidth
      Boolean? filterPeaklists
      String? fixed
      Int? foffset
      String? frag
      Int? ftol
      String? ftolunits
      Int? lftol
      String? lftolunits
      String? localizationModification
      Float? minIntensity
      Int? minNumOfQuantitativePeaks
      Int? minQuantitativeIonNumber
      Float? numberOfExtraDecoyLibrariesSearche
      Int? numberOfQuantitativePeaks
      Float? percolatorProteinThreshold
      Float? percolatorThreshold
      Float? percolatorTrainingFDR
      Float? poffset
      Float? precursorIsolationMargin
      Float? precursorWindowSize
      Float? ptol
      String? ptolunits
      Float? rtWindowInMin
      String? scoringBreadthType
      Boolean? verifyModificationIons
    }

    String percolatorVersionNumber = if defined(encyclopedia_percolator_version)
        then "-percolatorVersionNumber " + encyclopedia_percolator_version
        else ""
    String percolatorTrainingSetSize = if defined(encyclopedia_percolator_trainingsetsize)
        then "-percolatorTrainingSetSize " + encyclopedia_percolator_trainingsetsize
        else ""
    String local_input_name = basename(input_file)

      # ${true='-filterPeaklists' false='' filterPeaklists} \
      # ${"-verifyModificationIons " + verifyModificationIons}

    command {
        set -e
        # EncyclopeDIA writes all output files the directory
        # which contains the mzML file. As a result we need to symlink the
        # input files into the local directory so that Cromwell will
        # be able to access the output files as OUTPUTs
        ln -s ${input_file} ./${local_input_name}

        java ${"-Xmx" + memory} \
        -jar /code/encyclopedia-${encyclopedia_version}-executable.jar \
        -i ${local_input_name} \
        ${"-f " + fasta} \
        ${"-l " + library_elib} \
        ${"-o " +  out_report_file} \
        ${"-numberOfThreadsUsed " + numberOfThreadsUsed} \
        ${"-acquisition " + acquisition} \
        ${"-enzyme " + enzyme} \
        ${"-expectedPeakWidth " + expectedPeakWidth} \
        ${"-fixed " + fixed} \
        ${"-foffset " + foffset} \
        ${"-frag " + frag} \
        ${"-ftol " + ftol} \
        ${"-ftolunits " + ftolunits} \
        ${"-lftol " + lftol} \
        ${"-lftolunits " + lftolunits} \
        ${"-localizationModification " + localizationModification} \
        ${"-minIntensity " + minIntensity} \
        ${"-minNumOfQuantitativePeaks " + minNumOfQuantitativePeaks} \
        ${"-minQuantitativeIonNumber " + minQuantitativeIonNumber} \
        ${"-numberOfExtraDecoyLibrariesSearche " + numberOfExtraDecoyLibrariesSearche} \
        ${"-numberOfQuantitativePeaks " + numberOfQuantitativePeaks} \
        ${"-percolatorProteinThreshold " + percolatorProteinThreshold} \
        ${"-percolatorThreshold " + percolatorThreshold} \
        ${"-percolatorTrainingFDR " + percolatorTrainingFDR} \
        ${percolatorTrainingSetSize} \
        ${percolatorVersionNumber} \
        ${"-poffset " + poffset} \
        ${"-precursorIsolationMargin " + precursorIsolationMargin} \
        ${"-precursorWindowSize " + precursorWindowSize} \
        ${"-ptol " + ptol} \
        ${"-ptolunits " + ptolunits} \
        ${"-rtWindowInMin " + rtWindowInMin} \
        ${"-scoringBreadthType " + scoringBreadthType} \
    }

    runtime {
        docker: "mauraisa/encyclopedia:${encyclopedia_version}"
    }

    output {
        File output_report_file = basename("${input_file}") + ".encyclopedia.txt"
        File output_decoy_file = basename("${input_file}") + ".encyclopedia.decoy.txt"
        File features_file = basename("${input_file}") + ".features.txt"
        File dia_file = basename("${input_file}", ".mzML") + ".dia"
        File mzml_elib_file = basename("${input_file}") + ".elib"
    }

    parameter_meta {
        memory: "Amount of memory to use for EncyclopeDIA run"
    }

    meta {
        author: "Brian Connolly"
        email: "bdconnol@uw.edu"
        description: "Execute encyclopeDIA"
    }
}


task export_library {
    input {
      Array[File] mzml_files
      Array[File] dia_files
      Array[File] features_files
      Array[File] encyclopedia_txt_files
      Array[File]? encyclopedia_decoy_txt_files
      Array[File]? mzml_elib_files
      File fasta
      File library_elib
      String encyclopedia_version
      String memory = "48g"
      Int? numberOfThreadsUsed
      String? encyclopedia_percolator_version
      String? encyclopedia_percolator_trainingsetsize
      String output_library_file
      String? align_between_files
      String? blib
      String? fixed
      Int? foffset
      Int? ftol
      String? ftolunits
      Int ?lftol
      String? lftolunits
      String? localizationModification
      Int? minNumOfQuantitativePeaks
      Int? minQuantitativeIonNumber
      Float ?numberOfExtraDecoyLibrariesSearche
      Int? numberOfQuantitativePeaks
      String? percolatorLocation
      Float? percolatorProteinThreshold
      Float? percolatorThreshold
    }

    String percolatorVersionNumber = if defined(encyclopedia_percolator_version)
        then "-percolatorVersionNumber " + encyclopedia_percolator_version
        else ""
    String percolatorTrainingSetSize = if defined(encyclopedia_percolator_trainingsetsize)
        then "-percolatorTrainingSetSize " + encyclopedia_percolator_trainingsetsize
        else ""


    command {
        set -e
        # EncyclopeDIA assumes that all mzML, DIA, features and encyclopedia.txt
        # and elib files will be located in a single directory. The code below will
        # create symlinks from the INPUTS files to the working directory.
        # symlink input_files
        for f in ${sep=' ' mzml_files}; do ln -s "$f" "./$(basename $f)"; done

        # symlink dia files
        for f in ${sep=' ' dia_files}; do ln -s "$f" "./$(basename $f)"; done

        # symlink features files
        for f in ${sep=' ' features_files}; do ln -s "$f" "./$(basename $f)"; done

        # symlink encyclopedia.txt files
        for f in ${sep=' ' encyclopedia_txt_files}; do ln -s "$f" "./$(basename $f)"; done

        # symlink encyclopedia.decoy.txt files. These are only needed when creating quant library.
        # Since these are optional, I need to check if the variable has been specified.
        # If not specified, then skip creating the symlink
        encyclopedia_decoy_txt="${sep=' ' encyclopedia_decoy_txt_files}"
        if [[ ! -z "$encyclopedia_decoy_txt" ]]
        then
            for f in ${sep=' ' encyclopedia_decoy_txt_files}; do ln -s "$f" "./$(basename $f)"; done
        fi

        # symlink mzml.elib files. These are only needed when creating quant library.
        # Since these are optional, I need to check if the variable has been specified.
        # If not specified, then skip creating the symlink
        mzml_elib="${sep=' ' mzml_elib_files}"
        if [[ ! -z "$mzml_elib" ]]
        then
            for f in ${sep=' ' mzml_elib_files}; do ln -s "$f" "./$(basename $f)"; done
        fi

        # Run encyclopedia
        java ${"-Xmx" + memory} \
        -jar /code/encyclopedia-${encyclopedia_version}-executable.jar \
o       -libexport \
        -o ${output_library_file} \
        -i ./ \
        ${"-f " + fasta} \
        ${"-l " + library_elib} \
        ${"-a " + align_between_files} \
        ${"-blib " + blib} \
        ${"-fixed " + fixed} \
        ${"-foffset " + foffset} \
        ${"-ftol " + ftol} \
        ${"-ftolunits " + ftolunits} \
        ${"-lftol " + lftol} \
        ${"-lftolunits " + lftolunits} \
        ${"-localizationModification " + localizationModification} \
        ${"-minNumOfQuantitativePeaks " + minNumOfQuantitativePeaks} \
        ${"-minQuantitativeIonNumber " + minQuantitativeIonNumber} \
        ${"-numberOfExtraDecoyLibrariesSearche " + numberOfExtraDecoyLibrariesSearche} \
        ${"-numberOfQuantitativePeaks " + numberOfQuantitativePeaks} \
        ${"-numberOfThreadsUsed " + numberOfThreadsUsed} \
        ${"-percolatorLocation " + percolatorLocation} \
        ${"-percolatorProteinThreshold " + percolatorProteinThreshold} \
        ${"-percolatorThreshold " + percolatorThreshold} \
        ${percolatorVersionNumber} \
        ${percolatorTrainingSetSize}
    }

    runtime {
        docker: "mauraisa/encyclopedia:${encyclopedia_version}"
    }

    output {
        File output_library_elib = "${output_library_file}"
        File? peptides_report = basename("${output_library_file}") + ".peptides.txt"
        File? proteins_report = basename("${output_library_file}") + ".proteins.txt"
    }

    parameter_meta {
        memory: "Amount of memory to use for EncyclopeDIA run"
    }

    meta {
        author: "Brian Connolly"
        email: "bdconnol@uw.edu"
        description: "Execute encyclopeDIA to create chromatogram library"
    }
}

