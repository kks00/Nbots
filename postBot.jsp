<%@ page contentType = "text/html;charset=utf-8" %>

<%@ page import="java.util.*"%>

<html>   
    <body style="font-family: 'Nanum Gothic', sans-serif;" class="bg-light">        
        <div>
          <div class="container-fluid m-2 p-2">
            <p class="display-5 fw-bold">
                <svg xmlns="http://www.w3.org/2000/svg" width="50" height="50" fill="currentColor" class="bi bi-file-earmark-arrow-up" viewBox="0 0 16 16" style="margin-right: 10px;">
                    <path d="M8.5 11.5a.5.5 0 0 1-1 0V7.707L6.354 8.854a.5.5 0 1 1-.708-.708l2-2a.5.5 0 0 1 .708 0l2 2a.5.5 0 0 1-.708.708L8.5 7.707V11.5z"/>
                    <path d="M14 14V4.5L9.5 0H4a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2zM9.5 3A1.5 1.5 0 0 0 11 4.5h2V14a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h5.5v2z"/>
                </svg>
                Cafe Post Bot
            </p>
            <p class="col-md-8 fs-4">임시저장 해둔 글을 이용하여 여러 카페에 게시글을 한번에 올릴 수 있습니다.</p>
          </div>
        </div>
        
        <div id="postBotAlertPlace" class="m-2 p-2"></div>
        
        <div class="border border-primary rounded m-3 p-3">
            <p><input type="text" class="form-control" placeholder="임시 게시글이 등록되있는 카페 URL" id="tempCafeUrl"></p>
            <p><input type="text" class="form-control" placeholder="게시글 등록 카페 URL" id="postCafeUrl"></p>
            <p><input type="button" class="btn btn-primary" onClick="btnLoadTempArticles(); btnLoadMenus();" value="설정"></p>
        </div>
        
        <div class="border border-primary rounded m-3 p-3">
            <p>
                <table class="table table-hover text-center" id="tempArticles" style="width: 100%; max-height: 30%; overflow-y: scroll;">
                    <thead>
                        <th width="10%"></th>
                        <th width="20%">게시글 ID</th>
                        <th width="70%">제목</th>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </p>
            <p>
                <select class="form-select" id="menus">
                </select>
            </p>
            <p>
                <input type="button" class="btn btn-outline-primary" onClick="checkAll()" value="전부 체크하기">
                <input type="button" class="btn btn-primary" value="글 추가하기" onClick="addArticles();">
            </p>
        </div>
    
        <div class="border border-primary rounded m-3 p-3" style="max-height: 30%; overflow-y: scroll;">
            <p>
                <table class="table table-hover text-center" id="processList" style="width: 100%;">
                    <thead>
                        <th min-width="15"></th>
                        <th min-width="85">타겟 카페 ID</th>
                        <th min-width="85">타겟 게시판 ID</th>
                        <th min-width="85">임시글 카페 ID</th>
                        <th min-width="85">임시글 ID</th>
                        <th min-width="100">임시글 제목</th>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </p>
            <p>
                <input type="button" class="btn btn-outline-danger" value="선택 항목 삭제" onClick="delSelectedProcess();">
                <input type="button" class="btn btn-outline-secondary" value="내보내기" onClick="exportProcessList();">
                <input type="button" class="btn btn-outline-secondary" value="가져오기" onClick="importProcessList();">
            </p>
            <p>
                <input type="button" class="btn btn-primary" value="글 전부 등록하기" onClick="btnPostArticles();">
                <button type="button" class="btn btn-primary" id="progressButton" data-bs-toggle="modal" data-bs-target="#progressModal">
                    진행 상태 보기
                </button>
            </p>
        </div>
        
        <script>
            var currentTempClubId = "";
            var currentTargetClubId = "";
            
            function delSelectedProcess() {
                var processList = document.querySelectorAll("#processList>tbody>tr");
                for (var i=0; i<processList.length; i++) {
                    var currentProcess = processList[i];
                    if (currentProcess.getElementsByClassName("checkBox")[0].checked) {
                        currentProcess.parentNode.removeChild(currentProcess);
                    }
                }
            }
            
            async function importProcessList() {
                var fileHandles = window.showOpenFilePicker();
                fileHandles
                    .then(function (result) {
                        var fileHandle = result[0].getFile();
                        fileHandle.then(function (result) {
                            var fileText = result.text();
                            fileText.then(function (result) {
                                var loadedJSON = JSON.parse(result);

                                if (confirm("등록되어 있던 글들을 모두 지우시겠습니까?")) {
                                    var trObjects = document.querySelectorAll("#processList>tbody>tr");
                                    for (var i=0; i<trObjects.length; i++) {
                                        trObjects[i].parentNode.removeChild(trObjects[i]);
                                    }
                                }

                                var processList = document.querySelector("#processList tbody");
                                var arrKeys = ["targetClubId", "menuId", "tempClubId", "articleId", "subject"];

                                for (var i=0; i<loadedJSON.length; i++) {
                                    var trObj = document.createElement("tr");
                                    trObj.setAttribute("class", "Article");

                                    var check_td = document.createElement("td");
                                    var check_input = document.createElement("input");
                                    check_input.setAttribute("type", "checkbox");
                                    check_input.setAttribute("class", "checkBox form-check-input");
                                    check_td.appendChild(check_input);
                                    trObj.appendChild(check_td);

                                    for (var j=0; j<arrKeys.length; j++) {
                                        var tdObj = document.createElement("td");
                                        tdObj.setAttribute("class", arrKeys[j]);
                                        tdObj.innerText = loadedJSON[i][arrKeys[j]];
                                        trObj.appendChild(tdObj);
                                    }
                                    processList.appendChild(trObj);
                                }
                            });
                        })
                    })
                    .catch(error => alert("가져오기를 취소합니다."));
            }
            
            async function exportProcessList() {
                var articlesJSON = new Array();
                var processList = document.getElementById("processList");
                var articles = processList.getElementsByClassName("Article");
                for (var i=0; i<articles.length; i++) {
                    var articleJSON = new Object();
                    var datas = articles[i].getElementsByTagName("td");
                    for (var j=0; j<datas.length; j++) {
                        var key = datas[j].getAttribute("class");
                        if (key != null)
                            articleJSON[key] = datas[j].innerText;
                    }
                    articlesJSON.push(articleJSON);
                }
                
                const opts = {
                    types: [{
                      description: 'JSON file',
                      accept: {'application/json': ['.json']},
                    }],
                };
                var fileHandles = window.showSaveFilePicker(opts);
                fileHandles
                    .then(async function (result) {
                        const fileHandle = result.getFile();
                        const writableStream = result.createWritable();
                        writableStream.then(async function (result) {
                            await result.write({ type: "write", data: JSON.stringify(articlesJSON) });
                            await result.close();
                        });
                    })
                    .catch(error => alert("내보내기를 취소합니다."));
            }
            
            function addArticles() {
                var processList = document.querySelector("#processList tbody");
                var articlesObj = document.querySelectorAll("#tempArticles .Article");
                
                for (var i=0; i<articlesObj.length; i++) {
                    if (articlesObj[i].getElementsByClassName("checkBox")[0].checked) {
                        var articleId = articlesObj[i].getElementsByClassName("ArticleId")[0].innerText;
                        var subject = articlesObj[i].getElementsByClassName("subject")[0].innerText;
                        
                        var trObj = document.createElement("tr");
                        trObj.setAttribute("class", "Article");
                        
                        var check_td = document.createElement("td");
                        var check_input = document.createElement("input");
                        check_input.setAttribute("type", "checkbox");
                        check_input.setAttribute("class", "checkBox form-check-input");
                        check_td.appendChild(check_input);
                        trObj.appendChild(check_td);
                        
                        var targetClubId_td = document.createElement("td");
                        targetClubId_td.setAttribute("class", "targetClubId");
                        targetClubId_td.innerText = currentTargetClubId;
                        trObj.appendChild(targetClubId_td);
                        
                        var menuId_td = document.createElement("td");
                        menuId_td.setAttribute("class", "menuId");
                        menuId_td.innerText = document.getElementById("menus").value;
                        trObj.appendChild(menuId_td);
                        
                        var tempClubId_td = document.createElement("td");
                        tempClubId_td.setAttribute("class", "tempClubId");
                        tempClubId_td.innerText = currentTempClubId;
                        trObj.appendChild(tempClubId_td);
                        
                        var articleId_td = document.createElement("td");
                        articleId_td.setAttribute("class", "articleId");
                        articleId_td.innerText = articleId;
                        trObj.appendChild(articleId_td);
                        
                        var subject_td = document.createElement("td");
                        subject_td.setAttribute("class", "subject");
                        subject_td.innerText = subject;
                        trObj.appendChild(subject_td);
                        
                        processList.appendChild(trObj);
                    }
                }
            }
            
            async function loadTempArticles() {
                function queryData(requestProcess, data) {
                    return new Promise(function (response) {
                        $.ajax({
                            type: "POST",
                            url: './postBot_process.jsp',
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
                
                var trObjects = document.querySelectorAll("#tempArticles tbody tr");
                for (var i=0; i<trObjects.length; i++) {
                    trObjects[i].parentNode.removeChild(trObjects[i]);
                }
                
                var tableObj = document.querySelector("#tempArticles tbody");
                
                var cafeUrl = document.getElementById("tempCafeUrl").value;
                await queryData("getClubId", "cafeUrl=" + cafeUrl).then(async function (responseJson) {
                    var clubId = responseJson["Result"]["clubid"];
                    currentTempClubId = clubId;

                    await queryData("getTempArticles", "clubid=" + clubId).then(async function (responseJson) {
                        var arrArticles = responseJson["Result"];
                        for (var i=0; i<arrArticles.length; i++) {
                            var currentArticle = arrArticles[i];

                            var trObj = document.createElement("tr");
                            trObj.setAttribute("class", "Article");

                            var check_td = document.createElement("td");
                            var check_input = document.createElement("input");
                            check_input.setAttribute("type", "checkbox");
                            check_input.setAttribute("class", "checkBox form-check-input");
                            check_td.appendChild(check_input);
                            trObj.appendChild(check_td);

                            var id_td = document.createElement("td");
                            id_td.setAttribute("class", "ArticleId");
                            id_td.innerText = currentArticle["ArticleId"];
                            trObj.appendChild(id_td);

                            var subject_td = document.createElement("td");
                            subject_td.setAttribute("class", "subject");
                            subject_td.innerText = currentArticle["subject"];
                            trObj.appendChild(subject_td);

                            tableObj.appendChild(trObj);
                        }
                    });
                });
            }
            
            function btnLoadTempArticles() {
                setTimeout(loadTempArticles, 0);
            }
            
            async function loadMenus() {
                function queryData(requestProcess, data) {
                    return new Promise(function (response) {
                        $.ajax({
                            type: "POST",
                            url: './postBot_process.jsp',
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
                
                var menuOptions = document.querySelectorAll("#menus>option");
                for (var i=0; i<menuOptions.length; i++) {
                    var currentNode = menuOptions[i];
                    currentNode.parentNode.removeChild(currentNode);
                }
                
                var menusObject = document.getElementById("menus");
                
                var cafeUrl = document.getElementById("postCafeUrl").value;
                await queryData("getClubId", "cafeUrl=" + cafeUrl).then(async function (responseJson) {
                    var clubId = responseJson["Result"]["clubid"];
                    currentTargetClubId = clubId;

                    await queryData("getMenus", "clubid=" + clubId).then(async function (responseJson) {
                        var arrMenus = responseJson["Result"];
                        for (var i=0; i<arrMenus.length; i++) {
                            var currentMenu = arrMenus[i];

                            var menuId = currentMenu["menuId"];
                            var menuName = currentMenu["menuName"];

                            var optionObj = document.createElement("option");
                            optionObj.setAttribute("value", menuId.toString());
                            optionObj.innerText = menuName;
                            menusObject.appendChild(optionObj);
                        }
                    });
                });
            }
            
            function btnLoadMenus() {
                setTimeout(loadMenus, 0);
            }
            
            async function postArticles() {
                function putAlert(type, message) {
                    var alertPlace = document.querySelector("#postBotAlertPlace");
                    var wrapper = document.createElement('div')
                    wrapper.innerHTML = '<div class="alert alert-' + type + ' alert-dismissible" role="alert">' + message + '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button></div>'
                    alertPlace.append(wrapper)
                }
                
                function sendPostArticle(tempClubId, temporaryArticleId, targetClubId, menuId) {
                    return new Promise(function (onSuccess, onFailed) {
                        $.ajax({
                            type: "POST",
                            url: './postTempArticle.jsp',
                            dataType: "text",
                            data: "&tempClubId=" + tempClubId + "&temporaryArticleId=" + temporaryArticleId + "&targetClubId=" + targetClubId + "&menuId=" + menuId,
                            async: true,
                            success: function (data, textStatus, jqXHR){
                                var responseJson = JSON.parse(data);
                                if (responseJson["result"] != null) {
                                    onSuccess();
                                } else {
                                    onFailed();
                                }
                            },
                            error: function (jqXHR, textStatus, thrownError){
                                onFailed();
                            },
                        });
                    })
                    
                }
                
                const _sleep = (delay) => new Promise((resolve) => setTimeout(resolve, delay));
                
                var successCnt = 0;
                var errorCnt = 0;
                
                putAlert("primary", "게시글 등록을 시작합니다. 도배 차단 방지를 위해 각 게시글 등록은 10초정도 소요됩니다.");
                
                var modalTitle = document.querySelector("#progressModal .modal-title");
                var modalProgressBar = document.querySelector("#progressModal .progress-bar");
                modalTitle.innerText = "게시글 등록중"
                
                var processList = document.getElementById("processList");
                var articles = processList.getElementsByClassName("Article");
                modalProgressBar.innerText = "0/" + articles.length;
                modalProgressBar.style.width = "0%";
                
                for (var i=0; i<articles.length; i++) {
                    modalProgressBar.innerText = String(i + 1) + "/" + articles.length;
                    modalProgressBar.style.width = String((i + 1) / articles.length * 100) + "%";
                    
                    var currentArticle = articles[i];
                    var tempClubId = currentArticle.getElementsByClassName("tempClubId")[0].innerText;
                    var tempArticleId = currentArticle.getElementsByClassName("articleId")[0].innerText;
                    var targetClubId = currentArticle.getElementsByClassName("targetClubId")[0].innerText;
                    var menuId = currentArticle.getElementsByClassName("menuId")[0].innerText;
                    
                    await sendPostArticle(tempClubId, tempArticleId, targetClubId, menuId).then(async function() {
                        successCnt++;
                        if (i < articles.length - 1)
                            await _sleep(10000);
                    }, function() {
                        errorCnt++;
                    });
                }
                
                modalTitle.innerText = "게시글 등록완료";
                putAlert("success", "게시글 등록완료! 성공 : " + successCnt + " / 실패 : " + errorCnt);
            }
            
            function btnPostArticles() {
                setTimeout(postArticles, 0);
            }
            
            function checkAll() {
                var articles = document.getElementById("tempArticles").getElementsByClassName("Article");
                for (var i=0; i<articles.length; i++) {
                    var currentArticle = articles[i];
                    currentArticle.getElementsByClassName("checkBox")[0].checked = true;
                }
            }
        </script>
    </body>
</html>
