echo 'cuda setup'
pip install --upgrade "jax[cuda12_pip]" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
python -c "import jax; print(f'Jax backend: {jax.default_backend()}')"
exit
