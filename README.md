# Complex-prediction

This will be a snakemake pipeline to predict complexes with
[Combfold](https://www.nature.com/articles/s41592-024-02174-0).

## Usage

This snakemake 🐍 project is powered by [pixi 🚀](https://prefix.dev/), it
handles _all_ of the dependencies (@me if it don't!). Installing the pipeline
involves the following steps:

```bash
# Install pixi
curl -fsSL https://pixi.sh/install.sh | bash

# Print the help
pixi install

```

The hardware requirement is a CUDA 11.8 or higher enabled graphics driver. If
this is met, analysis can begin!

```
# Run the whole analysis pipeline from begining to end for all files in `data`
pixi run make
```

Usage in a HPC context is done with the

```
pixi run slurm
```

command, this will launch the Snakemake pipeline with the slurm executor. This
means each job is launched as a seperate job with one GPU allocator. This
behaviour is supported on the raven HPC system.

## Steps in the pipeline

The input data in the form of combfold formatted JSON files from `data` are
copied over to the `results/data` directory. First the structures of the pairs
are calculated using combfold. The best pairs are used to calculate higher order
structures. Following this, the combfold algorithm is used to calculate the
structure of the complex of the pairs and higher order pairs.

![Steps of the pipeline](resources/pipeline.png)

The colabfold step is done in paralel for each (higher order) pair. The outputs
of colabfold are captured by re-evaluating the job-graph after the the pairings
have been determined by Combfold.
