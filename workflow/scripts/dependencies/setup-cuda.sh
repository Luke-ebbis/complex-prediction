echo 'cuda setup'
pip install --upgrade "jax[cuda12_pip]" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
python -c "import jax; print(f'Jax backend: {jax.default_backend()}')"
export CUDA_HOME=/usr/local/cuda-11.2
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
export PATH=$CUDA_HOME/bin:$PATH

exit
