import os

include: "helpers.smk"
TOOLS_DIR = "tools"
## preprocess:
##    Preprocess the input JSON files.
##
rule preprocess:
  """When the sequences are too long to predict, cut them

  Note not yet implemented yet
  """
  input:
    "data/{protein_complex}.json"
  output:
    "results/data/{protein_complex}/{protein_complex}.json"
  shell:
    """
    cp {input} {output}
    """


## produce_fasta_pair:
##    Convert the json's to fasta inputs.
##
checkpoint produce_fasta_pairs:
  """Make the fasta for larger subunit pairs
  """
  conda: "../envs/CombFold.yml"
  input:
    "results/data/{protein_complex}/{protein_complex}.json",
    "results/.checkpoints/installed_CombFold"
  output:
    directory("results/data/{protein_complex}/subunits/fasta-pairs/")
  params:
    max_size=3000
  shell:
    """
    python3 {TOOLS_DIR}/CombFold/scripts/prepare_fastas.py {input[0]} \
      --stage pairs --output-fasta-folder {output[0]} \
      --max-af-size {params.max_size}
    """


## produce_fasta_groups:
##    Determine which higher order-groups are most usefull to predict models
##    for.
##
checkpoint produce_fasta_groups:
  conda: "../envs/CombFold.yml"
  input:
    "results/data/{protein_complex}/{protein_complex}.json",
    "results/data/{protein_complex}/subunits/pair-pdb",
    "results/.checkpoints/installed_CombFold"
  output:
    directory("results/data/{protein_complex}/subunits/fasta-groups/")
  params:
    max_size=3000
  shell:
    """
    set +e # don't fail if there are no good pairs.
    python3 {TOOLS_DIR}/CombFold/scripts/prepare_fastas.py {input[0]} \
      --stage groups --output-fasta-folder {output[0]} \
      --max-af-size {params.max_size} \
      --input-pairs-results {input[1]}
    """

## combfold:
##    Calculate the protein complexes from the (higher order) pairs
##    predicted by the colabfold steps.
##
checkpoint combfold:
  """Run the combfold programme

  Note --- If a high scoring assembly cannot be found, the programme will
            exit with a nonzero exit code. That is why the usage of
            `set +e` is needed.
  """
  conda: "../envs/CombFold.yml"
  input:
    "results/.checkpoints/installed_CombFold",
    json="results/data/{protein_complex}/{protein_complex}.json",
    pdb="results/data/{protein_complex}/subunits/pdb"
  output:
    directory("results/data/{protein_complex}/combfold")
  resources:
    mem_mb=12000
  threads: 15
  shell:
    """
    mkdir {output} -p
    set +e
    python3  {TOOLS_DIR}/CombFold/scripts/run_on_pdbs.py {input.json}  \
      {input.pdb} {output}
    """

def get_combfold_structures_here(wildcards):
  output_folder = checkpoints.combfold.get(**wildcards).output[0]
  pdbs = [f for f in os.listdir(f"{output_folder}/assembled_results") if 
    f.endswith(".pdb") or f.endswith("cif")].pop()
  return f"{output_folder}/assembled_results/{pdbs}"


