from alphafold.relax import relax
from alphafold.relax import utils
from alphafold.common import protein, residue_constants
import Bio.PDB
from Bio.SeqIO import PdbIO, FastaIO
from Bio import SeqIO
import os
import itertools
import argparse
from typing import List, Tuple, Set, Dict
import logging
import sys

logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s - %(levelname)s - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S',
                    filemode='w')
console_handler = logging.StreamHandler(sys.stdout)
console_handler.setLevel(logging.DEBUG)
console_handler.setFormatter(
logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'))
logger = logging.getLogger()
MODRES = {'MSE':'MET','MLY':'LYS','FME':'MET','HYP':'PRO',
          'TPO':'THR','CSO':'CYS','SEP':'SER','M3L':'LYS',
          'HSK':'HIS','SAC':'SER','PCA':'GLU','DAL':'ALA',
          'CME':'CYS','CSD':'CYS','OCS':'CYS','DPR':'PRO',
          'B3K':'LYS','ALY':'LYS','YCM':'CYS','MLZ':'LYS',
          '4BF':'TYR','KCX':'LYS','B3E':'GLU','B3D':'ASP',
          'HZP':'PRO','CSX':'CYS','BAL':'ALA','HIC':'HIS',
          'DBZ':'ALA','DCY':'CYS','DVA':'VAL','NLE':'LEU',
          'SMC':'CYS','AGM':'ARG','B3A':'ALA','DAS':'ASP',
          'DLY':'LYS','DSN':'SER','DTH':'THR','GL3':'GLY',
          'HY3':'PRO','LLP':'LYS','MGN':'GLN','MHS':'HIS',
          'TRQ':'TRP','B3Y':'TYR','PHI':'PHE','PTR':'TYR',
          'TYS':'TYR','IAS':'ASP','GPL':'LYS','KYN':'TRP',
          'CSD':'CYS','SEC':'CYS'}


def pdb_to_string(pdb_file, chains=None, models=[1]):
  """read pdb file and return as string

  Written by the colabfold team
  github/sokrypton/ColabFold/blob/main/beta/relax_amber.ipynb
  """

  if chains is not None:
    if "," in chains: chains = chains.split(",")
    if not isinstance(chains,list): chains = [chains]
  if models is not None:
    if not isinstance(models,list): models = [models]

  modres = {**MODRES}
  lines = []
  seen = []
  model = 1
  for line in open(pdb_file,"rb"):
    line = line.decode("utf-8","ignore").rstrip()
    if line[:5] == "MODEL":
      model = int(line[5:])
    if models is None or model in models:
      if line[:6] == "MODRES":
        k = line[12:15]
        v = line[24:27]
        if k not in modres and v in residue_constants.restype_3to1:
          modres[k] = v
      if line[:6] == "HETATM":
        k = line[17:20]
        if k in modres:
          line = "ATOM  "+line[6:17]+modres[k]+line[20:]
      if line[:4] == "ATOM":
        chain = line[21:22]
        if chains is None or chain in chains:
          atom = line[12:12+4].strip()
          resi = line[17:17+3]
          resn = line[22:22+5].strip()
          if resn[-1].isalpha(): # alternative atom
            resn = resn[:-1]
            line = line[:26]+" "+line[27:]
          key = f"{model}_{chain}_{resn}_{resi}_{atom}"
          if key not in seen: # skip alternative placements
            lines.append(line)
            seen.append(key)
      if line[:5] == "MODEL" or line[:3] == "TER" or line[:6] == "ENDMDL":
        lines.append(line)
  return "\n".join(lines)


def relax_me(pdb_in, pdb_out, max_iterations, tolerance, stiffness, use_gpu):
    """Relaxing a pdb file

    Parameters
    ==========
    


    Written by the colabfold team
    github/sokrypton/ColabFold/blob/main/beta/relax_amber.ipynb
    """
    pdb_str = pdb_to_string(pdb_in)
    protein_obj = protein.from_pdb_string(pdb_str)
    amber_relaxer = relax.AmberRelaxation( max_iterations=max_iterations,
                                          tolerance=tolerance,
                                          stiffness=stiffness,
                                          exclude_residues=[],
                                          max_outer_iterations=3,
                                          use_gpu=use_gpu )
    relaxed_pdb_lines, _, _ = amber_relaxer.process(prot=protein_obj)
    with open(pdb_out, 'w') as f:
            logger.info(f"Wrote the relaxed structure to {pdb_out}")
            f.write(relaxed_pdb_lines)

def main():
    parser = argparse.ArgumentParser(
                        prog='Relaxation of protein structures',
                        description=f'Extract the primary structure from a protein file',
                        epilog='Sibbe Bakker')
    parser.add_argument('structure',
                    help="PDB file.")
    parser.add_argument('output',
                        help="Relaxed structure")
    args = parser.parse_args()
    input_file = args.inpput

if __name__ == "__main__":
    main()
