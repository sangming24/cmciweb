package com.cmci.home.service;

import com.cmci.common.service.CommonService;
import com.cmci.home.mapper.HomeMapper;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service("value=com.cmci.home.service.HomeService")
public class HomeService extends CommonService implements HomeMapper {

    public Map<String, Object> selectUserInfo(String userIdParam) {
        return this.getMyBatisObject(userIdParam);
    }
}