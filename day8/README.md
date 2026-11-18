# Day 8: Complete the CRUD lifecycle and verify with a full test suite

Part of **Spring Boot Essentials: Build Your First Java API** on systemdrd.com.

TaskFlow is a small Spring Boot REST API for tasks: create, list, update and delete,
with an integration test (MockMvc) that walks the whole lifecycle.

## Prerequisites
- Java 21 (`java -version`)
- Maven 3.8+ (`mvn -v`)

## Run
    bash start.sh    # writes any missing files, runs the tests, prints PASS/FAIL, then a short demo
    bash stop.sh     # stops the demo server if it is still running

Expected verify output: `PASS` after `BUILD SUCCESS`, then the demo prints the API responses.

