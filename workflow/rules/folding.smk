
## colabfold:
##    Calculate the protein structures of the fasta files using Colabfold.
##
rule colabfold:
  conda:
    "../envs/fold.yml"
  input:
    fasta="results/data/{protein_complex}/subunits/fasta-{grouping}/{fasta_file}.fasta"
  params:
    number_of_models=config['colabfold']['number_of_models']
  output:
    directory("results/data/{protein_complex}/subunits/processed-{grouping}/{fasta_file}")
  shell:
    """
    echo "Starting colabfold, please see {output}/log.txt for the log"
    colabfold_batch {input.fasta} {output} --num-models {params.number_of_models}
    """
