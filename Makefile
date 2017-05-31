all:
	docker build -t jbquenot/pimcore_v5 . --build-arg PIMCORE_RELEASE=v5
	docker push jbquenot/pimcore_v5
