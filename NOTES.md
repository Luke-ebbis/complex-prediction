# Config and Snakemake

* https://stackoverflow.com/questions/45508579/snakemake-wildcards-or-expand-command

* https://lachlandeer.github.io/snakemake-econ-r-tutorial/wildcards-in-target-rules.html

```python
def getInputNames(wildcards):
  """

  See: https://stackoverflow.com/a/56934990
  """
  inputs = list()
  for s in os.listdir("data/"+wildcards.sample):
      input.append(os.path.join("data/",wildcards.sample,s))
  print(f"found input files {input}")
  return inputs
```
