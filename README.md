# Snakemake workflow: Atlas2Anvio

[![Snakemake](https://img.shields.io/badge/snakemake-≥5-brightgreen.svg)](https://snakemake.bitbucket.io)
[![Build Status](https://travis-ci.org/snakemake-workflows/Atlas2Anvio.svg?branch=master)](https://travis-ci.org/snakemake-workflows/Atlas2Anvio)

This snakemake script is an extension to [metagenome-atlas](https://github.com/metagenome-atlas/atlas).
It allows the genomes predicted by Atlas and the coverages of them to be visualized and post processed in [Anvi'o](http://merenlab.org/software/anvio/).

| **WARNING:** This extension is in development. And is not yet working properly as I have some problems with the Anvio commands. Contribution is welcome. |
| --- |


## Authors

* Silas Kieser (@silask)

## Usage

### Step 1: Run Metagenome Atlas

See the [docs](https://metagenome-atlas.rtfd.io/) for more details.


### Step 2: Install the extension

If you simply want to use this workflow, download and extract the latest release.
If you intend to modify and further develop this workflow, fork this repository. Please consider providing any generally applicable modifications via a pull request.

In any case, if you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this repository and, if available, its DOI (see above).

### Step 3: Execute workflow

Run the snakemake of the extension in the same working dir with the `-d atlas_working_dir` parameter


Test your configuration by performing a dry-run via

    snakemake -d atlas_working_dir -n

Execute the workflow locally via

    snakemake --cores $N -d atlas_working_dir

using `$N` cores or run it in a cluster environment via

    snakemake --cluster qsub --jobs 100 -d atlas_working_dir

or

    snakemake --drmaa --jobs 100 -d atlas_working_dir

See the [Snakemake documentation](https://snakemake.readthedocs.io) for further details.

## Testing

Tests cases are in the subfolder `.test`. They should be executed via continuous integration with Travis CI.
