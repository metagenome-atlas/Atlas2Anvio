

contigs_db="genomes/anvio/all_contigs.db"

bam_file="genomes/alignments/{sample}.bam"

localrules: anvio
rule anvio:
    input:
        "genomes/anvio/imported_clusters",
        "genomes/anvio/PROFILE.db",
        contigs_db



localrules: get_contigs
rule get_contigs:
    input:
        fasta_dir = directory("genomes/genomes")
    output:
        fasta=temp("genomes/anvio/all_contigs.fasta")
    shell:
        "cat {input}/*.fasta > {output}"


rule anvi_gen_contigs_database:
    input:
        rules.get_contigs.output
    output:
        contigs_db
    params:
        name='All genomes',
    threads:
        1
    resources:
        mem=20
    conda:
        "%s/anvio.yaml" % CONDAENV
    log:
        "logs/genomes/anvio/anvi_gen_contigs_database.log"
    shell:
        """
            anvi-gen-contigs-database -f {input} -o {output} -n '{params.name}' \
            --skip-gene-calling \
            --skip-mindful-splitting --split-length -1 |& tee {log}
        """


# rule anvi_run_hmms:
#     input:
#         contigs_db
#     output:
#         touch("anvio/runned_hmm")
#     params:
#         profile='mono-shared',
#         time=10*60
#     benchmark:
#         "logs/benchmark/anvi_run_hmms.txt"
#     threads:
#         8
#     resources:
#         mem=20
#     conda:
#         "%s/anvio.yaml" % CONDAENV
#     log:
#         "logs/genomes/anvio/anvi_run_hmms.log"
#     shell:
#         """
#             anvi-run-hmms -c {input} -T {threads} |& tee {log}
#         """
#
#
# rule anvi_run_ncbi_cogs:
#     input:
#         contigs_db
#     output:
#         touch("anvio/runned_cogs")
#     threads:
#         8
#     resources:
#         mem=20
#     conda:
#         "../envs/anvio.yaml"
#     log:
#         "logs/anvi_run_ncbi_cogs.log"
#     shell:
#         """
#             anvi-run-ncbi-cogs -c {input} -T {threads} |& tee {log}
#         """


rule anvi_profile:
    input:
        db=contigs_db,
        bam=bam_file,
        bai=bam_file+".bai"
    output:
        "genomes/anvio/sample_profiles/{sample}/PROFILE.db"
    params:
        outdir=lambda wc, output: os.path.dirname(output[0]),
    threads:
        8
    resources:
        mem=90
    conda:
        "%s/anvio.yaml" %CONDAENV
    log:
        "logs/genomes/anvio/profile_{sample}.log"
    shell:
        """
            rm -rf {params.outdir}   |& tee {log}      # outdir shouldn't exist bevore
            anvi-profile -i {input.bam} -c {input.db} -T {threads} \
            --output-dir {params.outdir} -S {wildcards.sample} \
            --skip-SNV-profiling |& tee {log}
        """

rule anvi_merge:
    input:
        db=contigs_db,
        profiles= expand(rules.anvi_profile.output,sample=SAMPLES)
    output:
        "genomes/anvio/PROFILE.db"
    params:
        outdir=lambda wc, output: os.path.dirname(output[0]),
    threads:
        1
    conda:
        "%s/anvio.yaml" %CONDAENV
    log:
        "logs/genomes/anvio/merge_profile.log"
    shell:
        """
            anvi-merge {input.profiles} \
            -o {params.outdir} \
            -c {input.db} \
            --skip-concoct-binning \
            --overwrite-output-destinations |& tee {log}
        """

rule anvi_import_binning_results:
    input:
        db=contigs_db,
        profiles= rules.anvi_merge.output,
        binning_results = "genomes/clustering/contig2genome.tsv"
    output:
        touch("genomes/anvio/imported_clusters")
    params:
        name= "genomes"
    threads:
        1
    conda:
        "%s/anvio.yaml" % CONDAENV
    log:
        "logs/genomes/anvio/import_bins.log"
    shell:
        """
            anvi-import-collection {input.binning_results} \
            -C {params.name} \
            -c {input.db} \
            -p {input.profiles} \
            --contigs-mode \
            |& tee {log}
        """

# anvi-interactive -p SAMPLES-MERGED/PROFILE.db -c contigs.db \
# --export-svg FILE_NAME.svg

#
# rule create_bam_index:
#     input:
#         "{file}.bam"
#     output:
#         "{file}.bam.bai"
#     conda:
#         "%s/required_packages.yaml" % CONDAENV
#     threads:
#         1
#     shell:
#         "samtools index {input}"
