# covid19

Repository replicating steps of "Computational Protocol for Assembly and 
Analysis of SARS-nCoV-2 Genomes" from 
[Dr Vinod Scaria's Lab](http://vinodscaria.rnabiology.org/covid-19)

## create conda env for packages
Install [anaconda](https://www.anaconda.com/distribution/).
* additional packages: entrez-direct for esearch/efetch
* sra-tools for srafiles download
* additional packages: snakemake for pipeline
* multiqc: combine fastqc output htmls
* clustalw: for MSA
```
conda create --name covid19 && conda activate covid19
conda install -c  bioconda -y fastqc trimmomatic samtools hisat2 bedtools \
bcftools seqtk varscan kraken22 krona megahit SPAdes spades quast mafft picard\
entrez-direct sra-tools  snakemake multiqc
conda install -c biobuilds clustalw
```
OR install via conda config yaml file:
```
conda env create -f covid19_condaenv.yml
```

## get hg38 genome &  SARS-CoV-2 genome, build hisat2 index
```
# execute from working directory. My working dir is covid19 
mkdir genome && cd genome
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_33/GRCh38.p13.genome.fa.gz
efetch -db sequences -format fasta -id  NC_045512.2 > NC_045512.2.fna
hisat2-build -p 4 GRCh38.p13.genome.fa GRCh38.p13.genome
hisat2-build NC_045512.2.fna NC_045512.2
```

## get SRA datasets
```
cd ..
mkdir data && cd data
bash ../scripts/getsrainfo.sh SRP251618
bash ../scripts/getsrr_wget.sh srrlist.txt
```


## download kraken2 db
```
cd .. && mkdir db && cd db
wget ftp://ftp.ccb.jhu.edu/pub/data/kraken2_dbs/minikraken_8GB_202003.tgz
tar -xvf minikraken_8GB_202003.tgz
```

## update db for Krona
```
cd <conda directory path>/envs/covid19/opt/krona/
./updateTaxonomy.sh
./updateAccessions.sh
```

## run snakemake pipeline
* needs to be run from working directory
* `config.yaml` needs to be changed accordingly
* list.txt is created by `getsrainfo.sh` while downloading SRR files. 
`list.txt` in required for the snakemake script. Copy `list.txt` to 
working directory.
```
cp data/list.txt .
```
Working directory tree view:
```bash
.
├── cluster.yaml
├── config.yaml
├── covid19_analysis.snakemake
├── data
├── db
├── genome
├── list.txt
└── runcovid19_analysis.sh
```
To check individual steps without running
```
snakemake -np -s covid19_analysis.snakemake
```
To run snakemake script in slurm based clusters.
* change `cluster.yaml` if needed.
```
sh runcovid19_analysis.sh
```
to run in local computer
```
snakemake -s covid19_analysis.snakemake -k --restart-times 1 
```
