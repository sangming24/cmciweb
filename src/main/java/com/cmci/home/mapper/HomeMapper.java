package com.cmci.home.mapper;

import java.util.Map;

public interface HomeMapper {
    Map<String, Object> selectUserInfo(String id);
}
