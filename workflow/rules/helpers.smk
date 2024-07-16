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

  

