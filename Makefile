IMAGE = jbquenot/pimcore_v5:$(shell git describe --all | sed -e 's|^.*/||')

all: build push

build:
	docker build -t $(IMAGE) . --build-arg PIMCORE_RELEASE=v5

push:
	docker push $(IMAGE)
