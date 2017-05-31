# Docker container for pimcore

This is a full-featured Pimcore install as a docker image.  It fulfills all
system requirements as well as all best practices, such as caching.  So this
configuration can be seen as a reference how to set up a suitable server for
pimcore following best practices. 

## Building from source without demo data

Choose between `v5` (upcoming Pimcore 5.x labelled `unstable`) and `v4` (stable 4.x series):

```
docker build -t pimcore . --build-arg PIMCORE_RELEASE=v5
docker run --name pimcore -d -p 4321:80 pimcore
```

Point your browser to http://localhost:4321/install/ (v4) or
http://localhost:4321/install.php (v5) and enter the following information:

- Username: pimcore
- Database: pimcore

Choose an admin login and password, and voilà!
