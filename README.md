# test-api
Tiny docker container that runs a single endpoint API which returns the hostname of the docker container. This is useful
for testing out docker setups.

## Local testing

You can run `docker-compose build && docker-compose up` and hit the API at http://localhost:8000/ to see what it looks
like.