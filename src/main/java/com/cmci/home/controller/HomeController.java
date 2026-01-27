package com.cmci.home.controller;

import com.cmci.common.service.CommonService;
import com.cmci.common.util.CommonUtil;
import com.cmci.home.service.HomeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/home")
public class HomeController {

    @Autowired
    private HomeService service;

    @Autowired
    private CommonUtil commonUtil;

    @RequestMapping("/")
    public String home(Model model) {

        model.addAttribute("greeting", "hello world");

        return "home";
    }

    @RequestMapping("/view")
    public ModelAndView view(String param) {
        ModelAndView mv = new ModelAndView();
        mv.addObject("greeting", "hello world - View");
        mv.addObject("obj", service.selectUserInfo("abcd00000000000001"));
        mv.setViewName("/home/view");
        return mv;
    }

    @RequestMapping("/getPythonResult")
    public ResponseEntity<String> getPythonResult(String type) {
        if("SSIM".equals(type)) {
            String encodedImgByte = java.util.Base64.getEncoder().encodeToString(commonUtil.getPythonResultSsim());

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"python_result_ssim.jpg\"")
                    .contentType(MediaType.IMAGE_JPEG)
                    .body(encodedImgByte);
        }

        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @RequestMapping("/getRestPythonResult")
    public ResponseEntity<String> getRestPythonResult(String type) {
        List<String> imgPaths = new ArrayList<>();
        imgPaths.add("D:\\workspace_py\\imgWebTest\\uploads\\img1.jpg");
        imgPaths.add("D:\\workspace_py\\imgWebTest\\uploads\\img2.jpg");

        if("SSIM".equals(type)) {
            List<byte[]> targetImgList = new ArrayList<>();
            for(String imgPath : imgPaths) {
                File imgFile = new File(imgPath);
                if(!imgFile.exists() || !imgFile.isFile()) {
                    System.out.println("No File Exists : " +imgPath);
                }
                try {
                    targetImgList.add(Files.readAllBytes(imgFile.toPath()));
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            }

            String encodedImgByte = java.util.Base64.getEncoder().encodeToString(commonUtil.getPythonResultSsimWithFileTarget(targetImgList));

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"python_result_ssim.jpg\"")
                    .contentType(MediaType.IMAGE_JPEG)
                    .body(encodedImgByte);
        }

        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }
}