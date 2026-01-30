package com.cmci.user.controller;

import com.cmci.user.constants.UserExcelConstants;
import com.cmci.user.model.UserDto;
import com.cmci.user.service.UserExcelService;
import com.cmci.user.service.UserService;
import org.apache.poi.xslf.usermodel.XMLSlideShow;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import javax.servlet.http.HttpServletRequest;
import java.io.File;
import java.util.UUID;

@Controller
@RequestMapping("/user")
public class UserController {

    @Autowired
    private UserService service;

    @Autowired
    private UserExcelService excelService;

    @RequestMapping("/getUserInfo")
    @ResponseBody
    public UserDto getUserInfo(final String pUserId) {
        return service.getUserInfo(pUserId);
    }

    @RequestMapping("/chkValidation")
    @ResponseBody
    public UserDto chkValidation(final UserDto pDto) {
        UserDto rDto = new UserDto();
        rDto.setChkResult(service.getUserInfo(pDto)==null?"success":"fail");
        return rDto;
    }

    @RequestMapping("/addUserInfo")
    @ResponseBody
    public UserDto addUserInfo(final UserDto pDto) {
        UserDto rDto = new UserDto();
        rDto.setAddCnt(service.addUserInfo(pDto));
        return rDto;
    }

    @RequestMapping("/exportPpt")
    public String exportPpt(MultipartHttpServletRequest pReq) {
        MultipartFile pptFile = pReq.getFile("pptTarget");
    //public String exportPpt(MultipartFile pptFile) {
        if(pptFile.isEmpty()) {
            return "FILE_EMPTY";
        }
        excelService.exportPptFile(pptFile);
        return pptFile.getName();
    }
}
