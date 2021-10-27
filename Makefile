TAG ?= latest
IMAGE_NAME ?= slac-ml
IMAGE ?= slaclab/slac-ml
IMAGE_PREFIX ?= /sdf/group/ml/software/images/

build:
	sudo docker build . -t $(IMAGE):$(TAG)

push:
	sudo docker push $(IMAGE):$(TAG)

singularity-dir:
	mkdir -p $(IMAGE_PREFIX)/$(IMAGE_NAME)/$(TAG)

singularity: singularity-dir
	singularity pull -F $(IMAGE_PREFIX)/$(IMAGE_NAME)/$(TAG)/$(IMAGE_NAME)@$(TAG).sif docker://$(IMAGE):$(TAG)

