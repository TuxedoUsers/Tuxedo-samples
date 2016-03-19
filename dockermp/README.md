# Introduction
This folder contains the information and examples of how to use [Tuxedo](http://oracle.com/tuxedo) with [Docker](https://www.docker.com/) to create an clustered Tuxedo application.

## Contents
It is based on the WebLogic Server dockerization (is that even a word?) done by Bruno Borges.

## To use
1. First run the docker project that creates a Tuxedo docker image containing the simpapp application
2. Pull the files from directory
3. Build the containers:  docker-compose build
4. Start the containers: docker-compose up -d
5. You should have 3 Docker containers (dockermp_node1_1, dockermp_node2_1, dockermp_node3_1) up and running at this point
6. Open a shell in dockermp_node1_1:  docker exec -it dockermp_node1_1 /bin/bash
7. Source the setenv.sh script:  source setenv.sh
8. Execute the simpappmp_runme.sh script:  sh ../simpappmp_runme.sh
9. You should now have a 3 node Tuxedo cluster with each node running a single copy of simpserv.
10. If you want to verify that the load was executed on multiple nodes do:
  a. tmadmin
  b. > d site1
  c. > psc
  d. > d site2
  e. > psc
  f. > d site3
  g. > psq
  h. > q
11. You should see that some of the client requests were done on one node, and some on another.

Have fun!



