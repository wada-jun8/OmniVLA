# Base image: CUDA 11.8 devel (Required for compiling FlashAttention)
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

# Prevent interactive prompts during apt installation
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install system dependencies and build tools
RUN apt-get update && apt-get install -y \
    wget git curl build-essential \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh 
ENV PATH="/root/miniconda3/bin:${PATH}"

WORKDIR /app

# 3. Create Conda environment (Python 3.10)
# Note: Using conda-forge and overriding channels to avoid Anaconda ToS issues
RUN conda create -n omnivla python=3.10 -c conda-forge --override-channels -y

# 4. Set default shell to run commands inside the "omnivla" environment
SHELL ["conda", "run", "-n", "omnivla", "/bin/bash", "-c"]

# 5. Install NumPy (Specific version)
RUN pip install numpy==1.26.4

# 6. Install PyTorch (GPU version)
RUN pip install torch==2.2.0 torchvision==0.17.0 torchaudio==2.2.0 \
     --index-url https://download.pytorch.org/whl/cu118

# 7. Install Flash Attention 2
# Note: "psutil" is required for the build process. Compilation may take 10-20 mins.
RUN pip install packaging ninja psutil
RUN pip install "flash-attn==2.5.5" --no-build-isolation

# 8. Copy source code and install the package
COPY . /app/
RUN pip install -e .

# 9. Auto-activate Conda environment on container startup
RUN echo "source /root/miniconda3/etc/profile.d/conda.sh && conda activate omnivla" >> ~/.bashrc
