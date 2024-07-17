"""Helper rules
"""

TOOL_DIR = "tools"


rule prepare_github:
  """Make sure that the git submodules are availible.
  """
  output: touch("results/.checkpoints/git")
  shell: "git submodule init; git submodule update"

rule install_pixi:
  """If pixi is not yet present on the system"""
  output: touch("results/.checkpoints/pixi")
  shell: "curl -fsSL https://pixi.sh/install.sh | bash"
  

rule install_submodule:
  conda:
    "../envs/{tool}.yml"
  input: 
    git="results/.checkpoints/git",
  output:
    tool=touch("results/.checkpoints/installed_{tool}")
  shell:
    """
    cd "{TOOL_DIR}/{wildcards.tool}"

    bash install.sh
    """


# Function to get the list of produced FASTA files -- CHATGPT
def get_fasta_files(wildcards):
    checkpoint_output = checkpoints.produce_fasta_pairs.get(**wildcards).output[0]
    fasta_files = [os.path.join(checkpoint_output, f) for f in
      os.listdir(checkpoint_output) if f.endswith(".fasta")]
    return fasta_files


# Function to get the list of produced pdb files -- CHATGPT
def get_pdb_files_pairs(wildcards):
    checkpoint_output = checkpoints.produce_fasta_pairs.get(**wildcards).output[0]
    fasta_files = [os.path.join(checkpoint_output, f) for f in
      os.listdir(checkpoint_output) if f.endswith(".fasta")]
    pdb_file = [(file
      .replace("fasta-pairs", "processed-pairs")
      .replace(".fasta", "")) 
      for file in fasta_files]
    return pdb_file

    
def get_pdb_files_groups(wildcards):
    checkpoint_output = checkpoints.produce_fasta_groups.get(**wildcards).output[0]
    fasta_files = [os.path.join(checkpoint_output, f) for f in
      os.listdir(checkpoint_output) if f.endswith(".fasta")]
    pdb_file = [(file
      .replace("fasta-groups", "processed-groups")
      .replace(".fasta", "")) 
      for file in fasta_files]
    return pdb_file
  

rule gather_pdb_pairs:
  input:
    get_pdb_files_pairs
  output:
    directory("results/data/{protein_complex}/subunits/pair-pdb/")
  shell:
    """
    mkdir {output} -p
    echo "Copying PDB files to: {output}"
    for pdb_dir in {input}; do
      echo "Processing directory: $pdb_dir"
      echo "In this directory are the following files:"
      ls $pdb_dir -l
      cp "$pdb_dir"/*.pdb {output}
    done
    """


rule gather_pdb_groups:
  input:
    get_pdb_files_groups
  output:
    directory("results/data/{protein_complex}/subunits/group-pdb/")
  shell:
    """
    mkdir {output} -p
    echo "Copying PDB files to: {output}"
    for pdb_dir in {input}; do
      echo "Processing directory: $pdb_dir"
      echo "In this directory are the following files:"
      ls $pdb_dir -l
      cp "$pdb_dir"/*.pdb {output}
    done
    """

rule gather_pdb:
  input:
    pairs="results/data/{protein_complex}/subunits/pair-pdb",
    groups="results/data/{protein_complex}/subunits/group-pdb"
  output: 
    directory("results/data/{protein_complex}/subunits/pdb")
  shell:
    """
    cpalways () { cp $1 $2 2>/dev/null ; return 0 ; }
    echo "Collating the structures..."
    ls {input.pairs} -l
    ls {input.groups} -l
    mkdir {output} -p
    cp {input.pairs}/*pdb {output}
    cpalways {input.groups}/*pdb {output}
    """
