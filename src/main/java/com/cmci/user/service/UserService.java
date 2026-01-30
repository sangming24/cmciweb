package com.cmci.user.service;

import com.cmci.common.service.CommonService;
import com.cmci.user.model.UserDto;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service(value="com.cmci.user.service.UserService")
public class UserService extends CommonService {

    public UserDto getUserInfo(String pUserId) {
        Map<String, String> pMap = new HashMap<>();
        pMap.put("id", pUserId);
        return (UserDto)this.selectOne("user.selectUserDto", pMap);
    }

    public UserDto getUserInfo(UserDto pDto) {
        Map<String, String> pMap = new HashMap<>();
        pMap.put("id", pDto.getUserId());
        return (UserDto)this.selectOne("user.selectUserDto", pMap);
    }

    public int addUserInfo(UserDto userDto) {
        return (int)this.insert("user.insertUserInfo", userDto);
    }
}
