package com.cmci.user.service;

import com.cmci.user.constants.UserExcelConstants;
import org.apache.poi.util.IOUtils;
import org.apache.poi.xslf.usermodel.XMLSlideShow;
import org.apache.poi.xslf.usermodel.XSLFSlide;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.*;
import java.nio.file.Files;
import java.util.List;
import java.util.UUID;

@Service(value="com.cmci.user.service..UserExcelService")
public class UserExcelService {

    public void exportPptFile(MultipartFile pptFile) {
        String uuid = UUID.randomUUID().toString().replace("-","");

        File tmpFolder = new File(UserExcelConstants.PPT_TMP_FOLDER+File.separator+uuid);
        if(!tmpFolder.exists())
            tmpFolder.mkdir();

        File targetFile = new File(UserExcelConstants.PPT_TMP_FOLDER+File.separator+uuid+File.separator+pptFile.getOriginalFilename());
        try {
            try(InputStream is = pptFile.getInputStream()) {
                FileOutputStream fos = new FileOutputStream(targetFile);
                IOUtils.copy(is, fos);
            }

            try(XMLSlideShow ppt = new XMLSlideShow(Files.newInputStream(targetFile.toPath()))) {
                exportPptInfos(ppt);
            }
        } catch(IOException ioe) {
            ioe.printStackTrace();
        }
    }

    private void exportPptInfos(XMLSlideShow ppt) {
        List<XSLFSlide> slides = ppt.getSlides();
        System.out.println("총 슬라이드 수: " + slides.size());

        // 슬라이드 루프 처리 가능
        for (XSLFSlide slide : slides) {
            // 데이터 추출 또는 수정 로직
        }
    }
}
