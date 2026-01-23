package com.example.employee.controller;

import com.example.employee.entity.Employee;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
public class EmployeeController {

    @GetMapping("/")
    public String health() {
        return "Application is running fine!";
    }

    @GetMapping("/employees")
    public List<Employee> getEmployees() {
        return List.of(
                new Employee(1, "Sanket", "DevOps Engineer"),
                new Employee(2, "Rahul", "Cloud Engineer")
        );
    }
}
