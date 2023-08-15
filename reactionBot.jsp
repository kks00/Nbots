<%@ page contentType = "text/html;charset=utf-8" %>

<%@ page import="java.util.*"%>

<html>
    <body style="font-family: 'Nanum Gothic', sans-serif;" class="bg-light">
        <div>
            <div class="container-fluid m-2 p-2">
              <p class="display-5 fw-bold">
                  <svg xmlns="http://www.w3.org/2000/svg" width="50" height="50" fill="currentColor" class="bi bi-people" viewBox="0 0 16 16" style="margin-right: 10px;">
                      <path d="M15 14s1 0 1-1-1-4-5-4-5 3-5 4 1 1 1 1h8zm-7.978-1A.261.261 0 0 1 7 12.996c.001-.264.167-1.03.76-1.72C8.312 10.629 9.282 10 11 10c1.717 0 2.687.63 3.24 1.276.593.69.758 1.457.76 1.72l-.008.002a.274.274 0 0 1-.014.002H7.022zM11 7a2 2 0 1 0 0-4 2 2 0 0 0 0 4zm3-2a3 3 0 1 1-6 0 3 3 0 0 1 6 0zM6.936 9.28a5.88 5.88 0 0 0-1.23-.247A7.35 7.35 0 0 0 5 9c-4 0-5 3-5 4 0 .667.333 1 1 1h4.216A2.238 2.238 0 0 1 5 13c0-1.01.377-2.042 1.09-2.904.243-.294.526-.569.846-.816zM4.92 10A5.493 5.493 0 0 0 4 13H1c0-.26.164-1.03.76-1.724.545-.636 1.492-1.256 3.16-1.275zM1.5 5.5a3 3 0 1 1 6 0 3 3 0 0 1-6 0zm3-2a2 2 0 1 0 0 4 2 2 0 0 0 0-4z"/>
                  </svg>
                  Blog Reaction Bot
              </p>
              <p class="col-md-8 fs-4">이웃의 최근 게시물에 공감과 댓글을 한번에 보낼 수 있습니다.</p>
            </div>
            
            <div id="reactionBotAlertPlace" class="m-2 p-2"></div>
            
            <div class="border border-primary rounded m-3 p-3">
                <p><input type="number" class="form-control" id="lastPostCount" placeholder="최근 게시글 개수"></p>
                <p>
                    <textarea class="form-control" id="comment" placeholder="댓글" rows=3 cols=30></textarea>
                </p>
            </div>
            
            <div class="border border-primary rounded m-3 p-3" style="max-height: 30%; overflow-y:scroll;">
                <p>
                    <input type="button" class="btn btn btn-primary" value="이웃 불러오기" onClick="btnLoadBuddies();">
                    <input type="button" class="btn btn-outline-primary" value="전부 선택하기" onClick="checkAllBuddies();">
                    <input type="button" class="btn btn btn-primary" value="선택된 이웃 최근 게시글 불러오기" onClick="btnLoadPosts();">
                </p>
                <p>
                    <table class="table table-hover text-center" id="buddies" style="width: 100%;">
                        <thead>
                            <th width="10%"></th>
                            <th width="20%">아이디</th>
                            <th width="20%">닉네임</th>
                            <th width="50%">블로그이름</th>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </p>
            </div>
        
            <div class="border border-primary rounded m-3 p-3" style="max-height: 30%; overflow-y:scroll;">
                <p>
                    <input type="button" class="btn btn-outline-primary" value="전부 선택하기" onClick="checkAllPosts();">
                    <input type="button" class="btn btn-primary" value="선택된 게시물에 작업 시작" onClick="btnReactAll();">
                </p>
                <p>
                    <table class="table table-hover text-center" id="posts" style="width: 100%;">
                        <thead>
                            <th width="5%"></th>
                            <th width="15%">아이디</th>
                            <th width="20%">포스트 넘버</th>
                            <th width="40%">제목</th>
                            <th width="20%">작성 시간</th>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </p>
            </div>
        </div>
        <script>
            function checkAllPosts() {
                var checkBoxes = document.querySelectorAll("#posts .post .checkBox");
                for (var i=0; i<checkBoxes.length; i++) {
                    checkBoxes[i].checked = true;
                }
            }

            async function reactAll() {
                function putAlert(type, message) {
                    var alertPlace = document.querySelector("#reactionBotAlertPlace");
                    var wrapper = document.createElement('div')
                    wrapper.innerHTML = '<div class="alert alert-' + type + ' alert-dismissible" role="alert">' + message + '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button></div>'
                    alertPlace.append(wrapper)
                }
                
                function sendComment(strBloggerId, strPostNum, strContents) {
                    return new Promise(function(onSuccess, onFailed) {
                        $.ajax({
                            type: "POST",
                            url: './sendComment.jsp',
                            dataType: "text",
                            data: "bloggerId=" + strBloggerId + "&postNum=" + strPostNum + "&contents=" + strContents,
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
                            }
                        });
                    });
                }
                
                function sendLike(strBloggerId, strPostNum) {
                    return new Promise(function(onSuccess, onFailed) {
                        $.ajax({
                            type: "POST",
                            url: './sendLike.jsp',
                            dataType: "text",
                            data: "bloggerId=" + strBloggerId + "&postNum=" + strPostNum,
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
                            }
                        });
                    });
                }
                
                const _sleep = (delay) => new Promise((resolve) => setTimeout(resolve, delay));
                
                var commentContents = document.querySelector("#comment").value;
                var checkedPosts = document.querySelectorAll("#posts .post .checkBox:checked");
                
                putAlert("primary", "작업을 시작합니다. 도배 차단 방지를 위하여 각 작업 당 1초가 소요됩니다. 선택한 개수 : " + checkedPosts.length);

                var commentCnt = 0;
                var likeCnt = 0;
                for (var i=0; i<checkedPosts.length; i++) {
                    var currentPost = checkedPosts[i].parentNode.parentNode;
                    var bloggerId = currentPost.getElementsByClassName("bloggerId")[0].innerText;
                    var logNo = currentPost.getElementsByClassName("logNo")[0].innerText;

                    await sendComment(bloggerId, logNo, commentContents).then(function() {
                        commentCnt++;
                    }, function() {});
                    await sendLike(bloggerId, logNo).then(function() {
                        likeCnt++;
                    }, function () {});
                    
                    await _sleep(1000);
                }

                putAlert("success", "작업을 완료하였습니다. 댓글 : " + commentCnt + " 공감 : " + likeCnt);
            }
            
            function btnReactAll() {
                setTimeout(reactAll, 0);
            }

            async function loadPosts() {
                function queryData(requestProcess, data) {
                    return new Promise(function (response) {
                        $.ajax({
                            type: "POST",
                            url: './reactionBot_process.jsp',
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

                var postsTable = document.querySelector("#posts tbody");
                var trObjects = document.querySelectorAll("#posts tbody tr");
                for (var i=0; i<trObjects.length; i++) {
                    trObjects[i].parentNode.removeChild(trObjects[i]);
                }

                var lastPostCount = document.querySelector("#lastPostCount").value;
                if (lastPostCount == "") {
                    alert("최근 게시글 개수가 지정되지 않았습니다.");
                    return;
                }

                var checkedBuddies = document.querySelectorAll("#buddies .buddy .checkBox:checked");
                for (var i=0; i<checkedBuddies.length; i++) {
                    var currentId = checkedBuddies[i].parentNode.parentNode.getElementsByClassName("blogId")[0].innerText;
                    await queryData("getPostList", "bloggerId=" + currentId + "&count=" + lastPostCount).then(function (requestResult) {
                        if (requestResult["Status"] == "Success") {
                            var postsArray = requestResult["Result"];
                            for (var j=0; j<postsArray.length; j++) {
                                var trObj = document.createElement("tr");
                                trObj.setAttribute("class", "post");

                                var check_td = document.createElement("td");
                                var check_input = document.createElement("input");
                                check_input.setAttribute("type", "checkbox");
                                check_input.setAttribute("class", "checkBox form-check-input");
                                check_td.appendChild(check_input);
                                trObj.appendChild(check_td);

                                var tdObj = document.createElement("td");
                                tdObj.setAttribute("class", "bloggerId");
                                tdObj.innerText = currentId;
                                trObj.appendChild(tdObj);

                                tdObj = document.createElement("td");
                                tdObj.setAttribute("class", "logNo");
                                tdObj.innerText = postsArray[j]["logNo"];
                                trObj.appendChild(tdObj);

                                tdObj = document.createElement("td");
                                tdObj.setAttribute("class", "title");
                                tdObj.innerText = decodeURI(postsArray[j]["title"]).replace(/\+/gi, " ");
                                trObj.appendChild(tdObj);

                                tdObj = document.createElement("td");
                                tdObj.setAttribute("class", "addDate");
                                tdObj.innerText = postsArray[j]["addDate"];
                                trObj.appendChild(tdObj);

                                postsTable.appendChild(trObj);
                            }
                        }
                    });
                }
            }
            
            function btnLoadPosts() {
                setTimeout(loadPosts, 0);
            }

            function checkAllBuddies() {
                var checkBoxes = document.querySelectorAll("#buddies .buddy .checkBox");
                for (var i=0; i<checkBoxes.length; i++) {
                    checkBoxes[i].checked = true;
                }
            }

            async function loadBuddies() {
                function queryData(requestProcess, data) {
                    return new Promise(function (response) {
                        $.ajax({
                            type: "POST",
                            url: './reactionBot_process.jsp',
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

                var buddiesTable = document.querySelector("#buddies tbody");
                var trObjects = document.querySelectorAll("#buddies tbody tr");
                for (var i=0; i<trObjects.length; i++) {
                    trObjects[i].parentNode.removeChild(trObjects[i]);
                }

                await queryData("getBuddyList", "").then(function (requestResult) {
                    var buddyArray = requestResult["Result"];
                    var paramArray = ["blogId", "nickName", "blogName"];

                    for (var i=0; i<buddyArray.length; i++) {
                        var trObj = document.createElement("tr");
                        trObj.setAttribute("class", "buddy");

                        var check_td = document.createElement("td");
                        var check_input = document.createElement("input");
                        check_input.setAttribute("type", "checkbox");
                        check_input.setAttribute("class", "checkBox form-check-input");
                        check_td.appendChild(check_input);
                        trObj.appendChild(check_td);

                        for (var j=0; j<paramArray.length; j++) {
                            var tdObj = document.createElement("td");
                            tdObj.setAttribute("class", paramArray[j]);
                            tdObj.innerText = buddyArray[i][paramArray[j]];
                            trObj.appendChild(tdObj);
                        }

                        buddiesTable.appendChild(trObj);
                    }
                });
            }
            
            function btnLoadBuddies() {
                setTimeout(loadBuddies, 0);
            }
        </script>
    </body>
</html>