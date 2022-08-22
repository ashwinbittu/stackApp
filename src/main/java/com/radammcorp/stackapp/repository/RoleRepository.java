package com.radammcorp.stackapp.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.radammcorp.stackapp.model.Role;

public interface RoleRepository extends JpaRepository<Role, Long>{
}
