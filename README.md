# test-docker-nginx

docker build . -t test-docker-nginx

docker run -d -p 9999:80 test-docker-nginx