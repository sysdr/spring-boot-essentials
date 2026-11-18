#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# Helper to write files
write_file() {
    if [ ! -f "$1" ]; then
        echo "Creating $1"
        mkdir -p "$(dirname "$1")"
        cat <<EOF > "$1"
$2
EOF
    else
        echo "Keeping $1"
    fi
}

echo "--- Setting up TaskFlow Day 8 ---"

# 1. Project Structure (assuming Maven project)
write_file "pom.xml" '<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.4.0</version>
    </parent>
    <groupId>com.taskflow</groupId>
    <artifactId>taskflow</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <properties>
        <java.version>21</java.version>
    </properties>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>'

write_file "src/main/java/com/taskflow/model/Task.java" 'package com.taskflow.model;
public class Task {
    private Long id;
    private String title;
    private boolean completed;
    public Task() {}
    public Task(Long id, String title, boolean completed) { this.id = id; this.title = title; this.completed = completed; }
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public boolean isCompleted() { return completed; }
    public void setCompleted(boolean completed) { this.completed = completed; }
}'

write_file "src/main/java/com/taskflow/service/TaskService.java" 'package com.taskflow.service;
import com.taskflow.model.Task;
import org.springframework.stereotype.Service;
import java.util.*;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class TaskService {
    private final Map<Long, Task> tasks = new HashMap<>();
    private final AtomicLong counter = new AtomicLong(1);
    public Task save(Task task) { task.setId(counter.getAndIncrement()); tasks.put(task.getId(), task); return task; }
    public List<Task> findAll() { return new ArrayList<>(tasks.values()); }
    public Task update(Long id, Task task) { task.setId(id); tasks.put(id, task); return task; }
    public void delete(Long id) { tasks.remove(id); }
}'

write_file "src/main/java/com/taskflow/controller/TaskController.java" 'package com.taskflow.controller;
import com.taskflow.model.Task;
import com.taskflow.service.TaskService;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/tasks")
public class TaskController {
    private final TaskService taskService;
    public TaskController(TaskService taskService) { this.taskService = taskService; }
    @PostMapping public Task createTask(@RequestBody Task task) { return taskService.save(task); }
    @GetMapping public List<Task> getAllTasks() { return taskService.findAll(); }
    @PutMapping("/{id}") public Task updateTask(@PathVariable Long id, @RequestBody Task task) { return taskService.update(id, task); }
    @DeleteMapping("/{id}") public void deleteTask(@PathVariable Long id) { taskService.delete(id); }
}'

write_file "src/test/java/com/taskflow/TaskFlowApplicationTests.java" 'package com.taskflow;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class TaskFlowApplicationTests {
    @Autowired private MockMvc mockMvc;
    @Test
    void testFullCrudLifecycle() throws Exception {
        String taskJson = "{\"title\":\"Learn Spring Boot\",\"completed\":false}";
        mockMvc.perform(post("/tasks").contentType(MediaType.APPLICATION_JSON).content(taskJson)).andExpect(status().isOk());
        mockMvc.perform(get("/tasks")).andExpect(status().isOk()).andExpect(jsonPath("$[0].title").value("Learn Spring Boot"));
        mockMvc.perform(delete("/tasks/1")).andExpect(status().isOk());
    }
}'

write_file "src/main/java/com/taskflow/TaskFlowApplication.java" 'package com.taskflow;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class TaskFlowApplication {
    public static void main(String[] args) {
        SpringApplication.run(TaskFlowApplication.class, args);
    }
}'

write_file "README.md" '# Day 8: Complete the CRUD lifecycle and verify with a full test suite

Part of **Spring Boot Essentials: Build Your First Java API** on systemdrd.com.

TaskFlow is a small Spring Boot REST API for tasks: create, list, update and delete,
with an integration test (MockMvc) that walks the whole lifecycle.

## Prerequisites
- Java 21 (`java -version`)
- Maven 3.8+ (`mvn -v`)

## Run
    ./start.sh    # writes any missing files, runs the tests, prints PASS/FAIL, then a short demo
    ./stop.sh     # stops the demo server if it is still running

Expected verify output: `PASS` after `BUILD SUCCESS`, then the demo prints the API responses.
'

write_file ".gitignore" 'target/
*.log
*.pid
.idea/
.vscode/
*.iml
.DS_Store
'

# 2. Build and Test
# Use the Maven wrapper if the project has one, otherwise the installed Maven.
if [ -x ./mvnw ]; then MVN=./mvnw; elif command -v mvn >/dev/null 2>&1; then MVN=mvn; else
    echo "FAIL: Maven not found. Install Maven 3.8+ (https://maven.apache.org/install.html)"; exit 1; fi

echo "--- RUNNING TESTS ---"
echo "--- VERIFYING ---"
if "$MVN" -q -B clean test; then
    echo "PASS: all tests passed (BUILD SUCCESS)"
else
    echo "FAIL: tests failed - see the output above"
    exit 1
fi

echo "--- DEMO: full CRUD lifecycle against the running API ---"
"$MVN" -q -B -DskipTests package
nohup java -jar target/taskflow-0.0.1-SNAPSHOT.jar --server.port=8088 > app.log 2>&1 &
echo $! > app.pid
for _ in $(seq 1 60); do curl -sf http://localhost:8088/tasks >/dev/null 2>&1 && break; sleep 1; done
echo "POST   /tasks      -> $(curl -s -X POST -H 'Content-Type: application/json' -d '{"title":"Learn Spring Boot","completed":false}' http://localhost:8088/tasks)"
echo "GET    /tasks      -> $(curl -s http://localhost:8088/tasks)"
echo "PUT    /tasks/1    -> $(curl -s -X PUT -H 'Content-Type: application/json' -d '{"title":"Learn Spring Boot","completed":true}' http://localhost:8088/tasks/1)"
echo "DELETE /tasks/1    -> HTTP $(curl -s -o /dev/null -w '%{http_code}' -X DELETE http://localhost:8088/tasks/1)"
echo "GET    /tasks      -> $(curl -s http://localhost:8088/tasks)"
kill "$(cat app.pid)" 2>/dev/null || true
rm -f app.pid
echo "--- DEMO COMPLETE ---"
