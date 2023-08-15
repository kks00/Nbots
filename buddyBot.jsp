<%@ page contentType = "text/html;charset=utf-8" %>

<%@ page import="java.util.*"%>

<html>
    <body style="font-family: 'Nanum Gothic', sans-serif;">
        <div class="bg-light">
            <div class="container-fluid m-2 p-2">
              <p class="display-5 fw-bold">
                  <svg xmlns="http://www.w3.org/2000/svg" width="50" height="50" fill="currentColor" class="bi bi-person-plus" viewBox="0 0 16 16" style="margin-right: 10px;">
                    <path d="M6 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6zm2-3a2 2 0 1 1-4 0 2 2 0 0 1 4 0zm4 8c0 1-1 1-1 1H1s-1 0-1-1 1-4 6-4 6 3 6 4zm-1-.004c-.001-.246-.154-.986-.832-1.664C9.516 10.68 8.289 10 6 10c-2.29 0-3.516.68-4.168 1.332-.678.678-.83 1.418-.832 1.664h10z"/>
                    <path fill-rule="evenodd" d="M13.5 5a.5.5 0 0 1 .5.5V7h1.5a.5.5 0 0 1 0 1H14v1.5a.5.5 0 0 1-1 0V8h-1.5a.5.5 0 0 1 0-1H13V5.5a.5.5 0 0 1 .5-.5z"/>
                  </svg>
                  Blog Buddy Bot
              </p>
              <p class="col-md-8 fs-4">블로그 포스트에 댓글을 단 사람들에게 서로이웃 요청을 한번에 보낼 수 있습니다.</p>
            </div>
        </div>
        
        <div id="buddyBotAlertPlace" class="m-2 p-2"></div>

        <div class="border border-primary rounded m-3 p-3">
            <p><input type="text" class="form-control" placeholder="블로거 ID" id="bloggerId"></p>
            <p><input type="text" class="form-control" placeholder="게시글 고유번호" id="postNo"></p>
            <p><input type="button" class="btn btn-primary" onClick="btnLoadComments();" value="설정"></p>
        </div>

        <div class="border border-primary rounded m-3 p-3">
            <textarea class="form-control" id="message" placeholder="Message" rows=3 cols=30></textarea>
        </div>

        <div class="border border-primary rounded m-3 p-3" style="max-height: 30%; overflow-y: scroll;">
            <p>
                <input type="button" class="btn btn-outline-primary" value="전부 체크하기" onClick="checkAllComments();">
                <input type="button" class="btn btn-primary" onclick="btnAddBuddyAll()" value="선택된 블로거 서로이웃 추가">
            </p>
            <p>
                <table class="table table-hover text-center" id="comments" style="width: 100%;">
                    <thead>
                        <th width="5%"></th>
                        <th width="15%">아이디</th>
                        <th width="15%">닉네임</th>
                        <th width="65%">댓글</th>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </p>
        </div>

        <script>           
            function checkAllComments() {
                var checkBoxes = document.querySelectorAll("#comments .comment .checkBox");
                for (var i=0; i<checkBoxes.length; i++) {
                    checkBoxes[i].checked = true;
                }
            }

            async function loadComments() {
                function queryData(requestProcess, data) {
                    return new Promise(function (response) {
                        $.ajax({
                            type: "POST",
                            url: './buddyBot_process.jsp',
                            dataType: "text",
                            data: "process=" + requestProcess + "&" + data,
                            async: true,
                            success: function (data, textStatus, jqXHR){
                                response(JSON.parse(data));
                            },
                            error: function (jqXHR, textStatus, thrownError){
                                response(null);
                            },
                        });
                    });
                }
                
                var comments = document.querySelectorAll("#comments .comment");
                for (var i=0; i<comments.length; i++) {
                    comments[i].parentNode.removeChild(comments[i]);
                }
                
                var commentsTable = document.querySelector("#comments tbody");
                var bloggerId = document.querySelector("#bloggerId").value;
                var postNo = document.querySelector("#postNo").value;

                await queryData("getComments", "bloggerId=" + bloggerId + "&postNo=" + postNo).then(function (commentsJSON) {
                    var paramArray = ["userid", "username", "contents"];
                    var commentsArray = commentsJSON["Result"];
                    for (var i=0; i<commentsArray.length; i++) {
                        var trObj = document.createElement("tr");
                        trObj.setAttribute("class", "comment");

                        var check_td = document.createElement("td");
                        var check_input = document.createElement("input");
                        check_input.setAttribute("type", "checkbox");
                        check_input.setAttribute("class", "checkBox form-check-input");
                        check_td.appendChild(check_input);
                        trObj.appendChild(check_td);

                        for (var j=0; j<paramArray.length; j++) {
                            var tdObj = document.createElement("td");
                            tdObj.setAttribute("class", paramArray[j]);
                            tdObj.innerText = commentsArray[i][paramArray[j]];
                            trObj.appendChild(tdObj);
                        }

                        commentsTable.appendChild(trObj);
                    }
                });
            }
            
            function btnLoadComments() {
                setTimeout(loadComments, 0);
            }

            async function addBuddyAll() {
                function putAlert(type, message) {
                    var alertPlace = document.querySelector("#buddyBotAlertPlace");
                    var wrapper = document.createElement('div')
                    wrapper.innerHTML = '<div class="alert alert-' + type + ' alert-dismissible" role="alert">' + message + '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button></div>'
                    alertPlace.append(wrapper)
                }
                
                function sendAddBuddy(strUserId, strMessage) {
                    return new Promise(function(onSuccess, onFailed) {
                        $.ajax({
                            type: "POST",
                            url: './buddyAdd.jsp',
                            dataType: "text",
                            data: "bloggerId=" + strUserId + "&message=" + strMessage,
                            async: true,
                            success: function (data, textStatus, jqXHR){
                                if (data.includes("SUCCESS")) {
                                    onSuccess();
                                } else {
                                    onFailed();
                                }
                            },
                            error: function (jqXHR, textStatus, thrownError){
                                onFailed();
                            },
                        });
                    });
                }
                
                var cntSuccess = 0;
                var cntError =0;

                var strMessage = document.querySelector("#message").value;
                var checkBoxes = document.querySelectorAll("#comments .comment .checkBox:checked");
                
                putAlert("primary", "서로이웃 추가를 시작합니다.");
                
                for (var i=0; i<checkBoxes.length; i++) {                    
                    var strUserId = checkBoxes[i].parentNode.parentNode.getElementsByClassName("userid")[0].innerText;
                    await sendAddBuddy(strUserId, strMessage).then(function() {
                        cntSuccess++;
                    }, function() {
                        cntError++;
                    });
                }
                
                putAlert("success", "서로이웃 추가완료! 성공 : " + cntSuccess + " / 실패 : " + cntError);
            }
            
            function btnAddBuddyAll() {
                setTimeout(addBuddyAll, 0);
            }
        </script>
    </body>
</html>