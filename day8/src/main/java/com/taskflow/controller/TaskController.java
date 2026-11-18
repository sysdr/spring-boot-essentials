package com.taskflow.controller;
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
}
