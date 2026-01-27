package com.cmci.common.service;

import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;

@Service("value=com.cmci.common.service.CommonApiService")
public class CommonApiService {
    private final RestTemplate restTemplate = new RestTemplate();

    public String callExternalApi(String url) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.IMAGE_JPEG);

            HttpEntity<String> entity = new HttpEntity<>(headers);

            // GET 요청
            ResponseEntity<String> response = restTemplate.exchange(
                    url,
                    HttpMethod.GET,
                    entity,
                    String.class
            );

            if(response.getStatusCode() == HttpStatus.OK) {
                return response.getBody();
            } else {
                return "API 호출 실패 : "+response.getStatusCode();
            }
        } catch (Exception e) {
            return "오류발생 : "+e.getMessage();
        }
    }

    public byte[] callExternalImageApi(String url) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.IMAGE_JPEG);

            HttpEntity<byte[]> entity = new HttpEntity<>(headers);

            // GET 요청
            ResponseEntity<byte[]> response = restTemplate.exchange(
                    url,
                    HttpMethod.GET,
                    entity,
                    byte[].class
            );

            if (response.getStatusCode() == HttpStatus.OK) {
                return response.getBody();
            } else {
                return null;
            }
        } catch (Exception e) {
            return null;
        }
    }

    public byte[] callExternalImageApi(String url, List<byte[]> fileList) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.IMAGE_JPEG);

            //String requestBody = "{ image1 : "+fileList.get(0)+", image2 : "+fileList.get(1)+"}";
            String requestBody ="{ image1 : "+"image1.jsp"+", image2 : "+"image2.jsp"+"}";
            HttpEntity<String> entity = new HttpEntity<>(requestBody, headers);

            // POST 요청
            ResponseEntity<byte[]> response = restTemplate.exchange(
                    url,
                    HttpMethod.POST,
                    entity,
                    byte[].class
            );

            if (response.getStatusCode() == HttpStatus.OK) {
                return response.getBody();
            } else {
                return null;
            }
        } catch (Exception e) {
            return null;
        }
    }
}
