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
[project]
name = "ml_project"
channels = ["conda-forge", "pytorch"]
platforms = ["linux-64","osx-arm64", "osx-64", "win-64"]

[dependencies] # read by pixi as [feature.default.dependencies]
python = "3.11.*"
numpy = ">1.23"
pytorch = {version = ">=2.0.1", channel = "pytorch"}
torchvision = {version = ">=0.15", channel = "pytorch"}

[tasks]
train = "python train.py"

# Define everything needed to create the perfect cuda environment
[feature.cuda]
# The set of platforms will be combined in the environments and
# the intersection will be taken to see which platforms are supported.
platforms = ["linux-64", "win-64"]
# pixi will check if the correct cuda version is installed
system-requirements = {cuda = "12.1"}
channels = ["nvidia", {channel = "pytorch", priority = -1}]
dependencies = {cuda = ">=12.1", pytorch-cuda = {version = "12.1.*", channel = "pytorch"}}
tasks = {train = "python train.py --cuda"}

[environments]
# all environments include the default feature
cuda = ["cuda"] # This is read as ["default", "cuda"]
