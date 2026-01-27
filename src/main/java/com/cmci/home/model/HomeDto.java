package com.cmci.home.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class HomeDto {
    private String id;
    private String userId;
    private String userPwd;
    private String userName;
    private String deptCode;
    private String deptName;
}
