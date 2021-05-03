# Container images

Directory containing container images used by this project

Basic workflow:

`./build.sh <directory-name>` - build locally container image

`PUSH=1 ./build.sh <directory-name>` - build locally container image and push it to remote registry

Image tag fetched from `config.sh` in each directory
