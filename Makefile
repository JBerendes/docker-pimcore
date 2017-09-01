IMAGE = jbquenot/pimcore_v5:$(shell git describe --all | sed -e 's|^.*/||')

all:
	docker build -t $(IMAGE) . --build-arg PIMCORE_RELEASE=v5
	docker push $(IMAGE)
