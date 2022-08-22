package com.radammcorp.stackapp.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.radammcorp.stackapp.model.User;

public interface UserRepository extends JpaRepository<User, Long> {
    User findByUsername(String username);
    User findById(long id);
    /*public void updateUser(User user)*/;
    
}
