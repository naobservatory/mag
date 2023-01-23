# nf-core/mag: NAO-specific documentation

Please see the [usage docs](https://nf-co.re/mag/usage) for general usage instructions on running the mag pipeline. This document contains information specific to the Nucleic Acid Observatory (NAO).

## Running the pipeline

### Running the pipeline on the [MIT Engaging cluster](https://engaging-web.mit.edu/eofe-wiki/)

For simplicity, there is a [`slurm_submit`](../slurm_submit) script that can be used to submit pipeline jobs on the Engaging cluster. It will automatically load the required modules and submit the pipeline to the cluster. After making any required modifications, the script can be used as follows:

```bash
sbatch slurm_submit
```

If you look into the SLURM submission script (see [here](../slurm_submit#L44)), you will see that it is running the pipeline using something like the following command:

```bash
nextflow run main.nf -c illumina.config -profile engaging -resume
```

Here, the `-c` parameter is used to specify the configuration file containing all of the (non-default) input parameters. The `-profile` parameter is used to specify the pipeline profile to use. In this case, the `engaging` profile is used to specify that the pipeline should be run on the Engaging cluster which will run the pipeline using Singularity and the SLURM executor to submit jobs to the cluster. The `-resume` parameter is used to resume a failed run from the point where it failed. This can be useful if you want to change the pipeline parameters and re-run the pipeline from the point where it failed.

### Specifying input parameters

Specifying input parameters and running the pipeline is described in the [usage docs](https://nf-co.re/mag/usage). In the example above, all input parameters can be specified in a configuration file, however, they can also be specified on the command line (which take precedence). Similarly, the input samples can be specified in a [samplesheet file]((https://nf-co.re/mag/usage#samplesheet-input-file)) or on the command line. I would generally recommend using input files for both the configuration and input files as well as storing them in this GitHub repo. This makes it easier to reproduce the results and to share the pipeline runs with others.

Therefore to run the pipeline, specify these two input files:
1. **Configuration (`-c`)** - containing the input parameters for the pipeline (see [`illumina.config`](../conf/illumina.config) for an example)
2. **Samplesheet (`--input`)** - containing paths to the input FASTQ files for each sample (see [`exp4.006_samplesheet.csv`](../data/exp4.006_samplesheet.csv) for an example). Either local paths or remote URLs/S3 paths can be used. In the case of remote files, the files will be downloaded to the local work directory (using the defined AWS credentials if required) before being processed by the pipeline.

_Sidenote: Input parameters with a single dash (`-`) are Nextflow input parameters, whereas parameters with a double dash (`--`) are pipeline input parameters._

### Running the pipeline on AWS

The pipeline has not yet been tested on AWS, but it should be possible to run it in a similar way to that describe above using the `docker` profile instead of `engaging`. The pipeline can be run on AWS Batch using the [`awsbatch`](https://github.com/nf-core/configs/blob/master/conf/awsbatch.config) profile. See the following documentation for an example of how this could be done using [Nextflow Tower](https://help.tower.nf/22.3/compute-envs/aws-batch).


## Debugging the pipeline

For some useful tips on debugging nf-core pipelines see the [nf-core troubleshooting docs](https://nf-co.re/docs/usage/troubleshooting). One of the most useful tips is to go to the `work` directory and look at the `.command.{out,err,log,run,sh}` files for each failed process. These files contain the output and command to replicate any errors, they can be used to quickly/iteratively replicate and fix the error.

For debugging, it is recommended to use the [`-resume`](https://www.nextflow.io/docs/latest/tracing.html#resuming-a-failed-workflow) parameter described above (personally, I use this parameter for all runs).

## Examples runs

| Experiment | Description | Samplesheet | Configuration | AWS S3 Results |
|------------|-------------|-------------|---------------|----------------|
| exp4.006 | Initial NAO generated llumina data | [`exp4.006_samplesheet.csv`](../data/exp4.006_samplesheet.csv) | [`illumina.config`](../conf/illumina.config) | [`s3://nao-illumina-private/exp4.006/mag_results`](https://s3.console.aws.amazon.com/s3/buckets/nao-illumina-private?region=us-east-1&prefix=exp4.006/mag_results/&showversions=false) |
| Rothman HTP | Public wastewater dataset from Rothman et al. for unenriched samples from the HTP site | [`rothman_htp_samplesheet.csv`](../data/rothman_htp_samplesheet.csv) | [`rothman_htp.config`](../conf/rothman_htp.config) | [`s3://nao-phil-public/mag/results_rothman_htp`](https://s3.console.aws.amazon.com/s3/buckets/nao-phil-public?region=us-east-1&prefix=mag/results_rothman_htp/&showversions=false) |

## Modifying the pipeline

### How is the pipeline structured?

Nextflow pipelines consist of two main file types:
1. `.nf` files that contain the pipeline code
    - [`main.nf`](../main.nf) is the main pipeline file that is executed when the pipeline is run, it can be thought of as a wrapper script/entry point
    - [`mag.nf`](../workflows/mag.nf) contains the main workflow and logic for the pipeline, including loading the processes, specifying the order in which they are executed, and channels, to load the input data and pass it between processes
    - [`modules/**.nf`](../modules) contains the individual modules that are used in the pipeline
2. `.config` files that contain the pipeline configuration
    - [`nextflow.config`](../nextflow.config) contains the default pipeline configuration for all parameters and profiles
    - [`conf/**.config`](../conf) contains additional pipeline configuration
        - [`base.config`](../conf/base.config) contains the configuration for the base profile (enabled by default), that specifies the resources and error strategy for each process
        - [`modules.config`](../conf/modules.config) contains the pipeline configuration for the modules including extra arguments for the tools and specifies what output files that get copied to the results directory
        - [`engaging.config`](../conf/engaging.config) contains the pipeline configuration for the Engaging cluster
        - [`illumina.config`](../conf/illumina.config) contains the pipeline configuration for Illumina data
        - [`rothman_htp.config`](../conf/rothman_htp.config) contains the pipeline configuration for the Rothman HTP dataset

### What changes have already been made?

To view the differences between the original nf-core/mag pipeline and the NAO version, you can [compare the two GitHub repos](https://github.com/nf-core/mag/compare/dev...naobservatory:mag:main)

The main changes are also described in the [CHANGELOG](../CHANGELOG.md).

### How to add a new module?

See the [geNomad PR](https://github.com/nf-core/mag/pull/364) for an example of how to add a new module to the pipeline.

In summary, you need to:

- Create a new module file in the [`modules`](../modules) directory
- Import the module in the [`mag.nf`](../workflows/mag.nf) workflow and connect the input and output channels
- Add the module configuration to the [`modules.config`](../conf/modules.config) configuration file
- Add any additional parameters to the [`nextflow.config`](../nextflow.config) file (and the [`nextflow_schema.json`](../nextflow_schema.json) file if they are input parameters)
- Add tests for the module to the [`ci.yml`](../.github/workflows/ci.yml) file (as well as an additional test profile the the relevant files if necessary)
- Update the [documentation](../docs)
- Update the [CHANGELOG](../CHANGELOG.md)