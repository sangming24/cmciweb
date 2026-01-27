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

<button id="pythonBtn">Python 결과</button>
<div id="pythonResult"></div>
<br>
<button id="pythonRestBtn">Python Rest 결과</button>
<div id="pythonRestResult"></div>
<script>
    $("#pythonBtn").on("click", function () {
        $.get('/webtest2/home/getPythonResult?type=SSIM', function (data) {
            $("#pythonResult").html("<img src='data:image/jpeg;base64, " + data + "' style='width:100%'>");
        });
        /*
        $.ajax({
            url : "/webtest2/home/getPythonResult",
            type : "GET",
            data : jQuery.param({type:"SSIM"}),
            dataType : "json",
            beforeSend : function () {
                $("#pythonResult").html("진행중....");
            },
            success : function (response) {
                $("#pythonResult").html(
                    "<img src='data:image/jpeg;base64,"+response+"' style='width:100%'> "
                );
            },
            error : function (xhr, status, error) {
                $("#pythonResult").html(
                    "<span style='color:red;'>에러 발생: " + error + "</span>"
                );
            }
        });
        */
    });

    $("#pythonRestBtn").on("click", function () {
        $.get('/webtest2/home/getRestPythonResult?type=SSIM', function (data) {
            $("#pythonRestResult").html("<img src='data:image/jpeg;base64, " + data + "' style='width:100%'>");
        });
    });
</script>
</body>
</html>