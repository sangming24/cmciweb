<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<html>
<head>
    <title>Home</title>
</head>
<body>

<h2>View Page</h2>

<p>${greeting}</p>
<p>Service : ${obj}</p>

<div>신규 생성</div>
<div>
    <table>
        <colgroup>
            <col width="200px;"/>
            <col width="*"/>
        </colgroup>
        <tr>
            <td>User ID</td>
            <td><input type="text" id="userId" name="userId" value="${obj.USER_ID}"/></td>
        </tr>
        <tr>
            <td>User Password</td>
            <td><input type="text" id="userPwd" name="userPwd" value="${obj.userPwd}"/></td>
        </tr>
        <tr>
            <td>User Name</td>
            <td><input type="text" id="userName" name="userName" value="${obj.userName}"/></td>
        </tr>
    </table>
</div>
<button id="userAddBtn">사용자 생성</button>
<br>
<div>File Upload - PPT</div>
<div>
    <table>
        <colgroup><col width="200px"><col width="*"/><col width="200px"/></colgroup>
        <tr>
            <td>PPT 파일</td>
            <td>
                <form id="fileUploadForm" enctype="multipart/form-data">
                    <input type="file" id="pptTarget" name="pptTarget" accept=".ppt, .pptx"/>
                </form>
            </td>
            <td><button id="pptUploadBtn">File Upload</button></td>
        </tr>
    </table>
</div>
<button id="pythonBtn">Python 결과</button>
<div id="pythonResult"></div>
<br>
<button id="pythonRestBtn">Python Rest 결과</button>
<div id="pythonRestResult"></div>
<script>
    $("#userAddBtn").on("click", function () {
        if(lfn_chkValidation()) {
            lfn_addUserInfo();
        } else {
            alert("사용자 ID 중복");
        }
    });

    $("#pythonBtn").on("click", function () {
        $.get('/webtest2/home/getPythonResult?type=SSIM', function (data) {
            $("#pythonResult").html("<img src='data:image/jpeg;base64, " + data + "' style='width:100%'>");
        });
    });

    $("#pythonRestBtn").on("click", function () {
        $.get('/webtest2/home/getRestPythonResult?type=SSIM', function (data) {
            $("#pythonRestResult").html("<img src='data:image/jpeg;base64, " + data + "' style='width:100%'>");
        });
    });

    $("#pptUploadBtn").on("click", function() {
        //$("#fileUploadForm").innerHtml("<input type='file")
        let formData = new FormData($("#fileUploadForm")[0]);
        $.ajax({
            type: 'POST',
            url: '/webtest/user/exportPpt', // Server URL
            data: formData,
            processData: false, // Prevent jQuery from processing data [1]
            contentType: false, // Prevent jQuery from setting content type [1]
            success: function(response) {
                alert('File uploaded successfully!');
            },
            error: function(e) {
                alert('Upload failed.');
            }
        });
    });

    function lfn_chkValidation() {
        $.ajax({
            url: "/webtest/user/chkValidation",
            type: "GET",
            data: jQuery.param({
                userId: $("#userId").val(),
                userPwd: $("#userPwd").val(),
                userName: $("#userName").val()
            }),
            dataType: "json",
            success: function (data) {
                return data.chkResult == "success";
            },
            error: function (xhr, status, error) {
                console.log("에러 발생: " + error);
            }

        });
    }

    function lfn_addUserInfo() {
        $.ajax({
            url: "/webtest/user/addUserInfo",
            type: "GET",
            data: jQuery.param({
                userId: $("#userId").val(),
                userPwd: $("#userPwd").val(),
                userName: $("#userName").val()
            }),
            dataType: "json",
            success: function (data) {
                alert("Add Cnt : " + data.addCnt);
            },
            error: function (xhr, status, error) {
                console.log("에러 발생: " + error);
            }

        });
    }
</script>
</body>
</html>