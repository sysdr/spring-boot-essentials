package com.taskflow.service;
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
}
