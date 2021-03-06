DOCKER_COMMAND=docker


docker:
	$(DOCKER_COMMAND) build -t jmchilton/planemo-server-2 .
