# Make configuration (Set default to 'run')
.PHONY: all setup run build rebuild push

# Default target: Running "make" executes "run"
all: run

IMAGE_NAME=wadajun8/omnivla-img:v1

# ==========================================================
# 1. Setup (Run only once: make setup)
# ==========================================================
setup:
	@echo "Installing Git LFS..."
	# if git-lfs is missing, please run 'sudo apt install git-lfs' manually.
	git lfs install
	
	@echo "Downloading model checkpoints..."
	# Added '|| true' to prevent errors if the directory already exists.
	git lfs clone https://huggingface.co/NHirose/omnivla-original || true
	git lfs clone https://huggingface.co/NHirose/omnivla-original-balance || true
	git lfs clone https://huggingface.co/NHirose/omnivla-finetuned-cast || true
	@echo "Setup Done!"

# ==========================================================
# 2. Run (Daily use: make run or just make)
# ==========================================================
run:
	docker run --gpus all -it --rm -v $(CURDIR):/app $(IMAGE_NAME)

# ==========================================================
# 3. Management / Development
# ==========================================================
build:
	docker build -t $(IMAGE_NAME) .

rebuild:
	docker build --no-cache -t $(IMAGE_NAME) .

push:
	docker push $(IMAGE_NAME)
