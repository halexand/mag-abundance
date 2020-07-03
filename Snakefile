configfile: "config.yaml"  

READS_DIR = config['reads_dir']
SAMPLE, = glob_wildcards(os.path.join(READS_DIR, "{sample}"))

SAMPLE_NAME = list(set([i.split('/')[0] for i in SAMPLE])) 

OUTPUTDIR = 'output'


rule all: 
    input: expand(os.path.join(OUTPUTDIR ,"{sample}.coverm.abundance.tab"), sample=SAMPLE_NAME) 

rule coverm_genome:
    input:
        r1 = os.path.join(READS_DIR,"{sample}", "{sample}" + "_1.fastq.gz"),
        r2 = os.path.join(READS_DIR,"{sample}", "{sample}" + "_2.fastq.gz"),  
    params:
        genome_dir = '/vortexfs1/omics/alexander/data/TARA/PRJEB4352-snakmake-output/high-quality-mags',
        tmpdir = '/vortexfs1/scratch/halexander/coverm-tmp'
        
    output:
        os.path.join(OUTPUTDIR ,"{sample}.coverm.abundance.tab") 
    conda:
        "coverm.yaml"
    shell:
        """
        mkdir -p {params.tmpdir}
        export TMPDIR={params.tmpdir} 
        coverm genome --coupled {input.r1} {input.r2} --genome-fasta-directory {params.genome_dir} --genome-fasta-extension fa --min-read-percent-identity 0.95 --min-read-aligned-percent 0.75 --output-format dense     --min-covered-fraction 0     --contig-end-exclusion 75     --trim-min 0.05     --trim-max 0.95 --proper-pairs-only --methods count length covered_bases covered_fraction reads_per_base mean variance trimmed_mean rpkm relative_abundance --threads 8 --bam-file-cache-directory /vortexfs1/scratch/halexander/tmp-bam/ > {output} 
        """
