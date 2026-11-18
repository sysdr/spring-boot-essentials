package com.taskflow;
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
}
