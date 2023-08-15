<%@ page contentType = "text/html;charset=utf-8" %>

<%@ page import="java.util.*"%>

<html>   
    <body style="font-family: 'Nanum Gothic', sans-serif;" class="bg-light">        
        <div>
          <div class="container-fluid m-2 p-2">
            <p class="display-5 fw-bold">
	            <svg xmlns="http://www.w3.org/2000/svg" width="50" height="50" fill="currentColor" class="bi bi-pencil-square" viewBox="0 0 16 16" style="margin-right: 10px;">
				  <path d="M15.502 1.94a.5.5 0 0 1 0 .706L14.459 3.69l-2-2L13.502.646a.5.5 0 0 1 .707 0l1.293 1.293zm-1.75 2.456-2-2L4.939 9.21a.5.5 0 0 0-.121.196l-.805 2.414a.25.25 0 0 0 .316.316l2.414-.805a.5.5 0 0 0 .196-.12l6.813-6.814z"/>
				  <path fill-rule="evenodd" d="M1 13.5A1.5 1.5 0 0 0 2.5 15h11a1.5 1.5 0 0 0 1.5-1.5v-6a.5.5 0 0 0-1 0v6a.5.5 0 0 1-.5.5h-11a.5.5 0 0 1-.5-.5v-11a.5.5 0 0 1 .5-.5H9a.5.5 0 0 0 0-1H2.5A1.5 1.5 0 0 0 1 2.5v11z"/>
				</svg>
                Comment Bot
            </p>
            <p class="col-md-8 fs-4">게시판의 최신 게시글에 일괄적으로 댓글을 남길 수 있습니다.</p>
          </div>
        </div>
        
        <div id="commentBotAlertPlace" class="m-2 p-2"></div>
        
        <div class="border border-primary rounded m-3 p-3">
	        <p><input type="text" class="form-control" placeholder="카페 URL" id="commentCafeUrl"></p>
	        <p><input type="button" class="btn btn-primary" onClick="CommentBot_btnLoadMenus();" value="게시판 불러오기"></p>
            <p>
                <select class="form-select" id="commentMenus">
                </select>
            </p>
            <p><textarea class="form-control" id="commentText" placeholder="댓글" rows=3 cols=30></textarea></p>
            <p>
                <input type="button" class="btn btn-primary" value="게시판 추가하기" onClick="addMenuBtn();">
            </p>
        </div>
        
        <div class="border border-primary rounded m-3 p-3" style="max-height: 30%; overflow-y: scroll;">
        	<p><input type="number" class="form-control" id="lastPostCount" placeholder="최근 게시글 개수"></p>
            <p>
                <input type="button" class="btn btn-outline-primary" value="전부 체크하기" onClick="checkAllCommentItems();">
                <input type="button" class="btn btn-primary" onclick="sendCommentBtn()" value="선택된 게시판에 작업 시작">
            </p>
            <p>
                <table class="table table-hover text-center" id="comments_queue" style="width: 100%;">
                    <thead>
                        <th width="5%"></th>
                        <th width="20%">카페ID</th>
                        <th width="20%">게시판 ID</th>
                        <th width="45%">댓글</th>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </p>
        </div>
        
        <script>
        	async function sendCommentAll() {
	            function queryData(requestProcess, data) {
	                return new Promise(function (response) {
	                    $.ajax({
	                        type: "POST",
	                        url: './commentBot_process.jsp',
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
	            
                function sendComment(cafeId, articleId, content) {
                    return new Promise(function(onSuccess, onFailed) {
                        $.ajax({
                            type: "POST",
                            url: './sendCafeComment.jsp',
                            dataType: "text",
                            data: "cafeId=" + cafeId + "&articleId=" + articleId + "&contents=" + content,
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
                
            	var comment_items = document.querySelectorAll("#comments_queue .comment");
            	for (var i = 0; i < comment_items.length; i++) {
            		var cur_comment_item = comment_items[i];
            		if (cur_comment_item.querySelector(".checkBox").checked) {
            			var cur_clubid = cur_comment_item.querySelector(".clubid").innerText;
            			var cur_menuid = cur_comment_item.querySelector(".menuid").innerText;
            			var cur_comment_text = cur_comment_item.querySelector(".comment_text").innerText;
            			
            			await queryData("getArticles", "clubid=" + cur_clubid + "&menuid=" + cur_menuid + "&count=100").then(function (requestResult) {
            				var posts_array = requestResult["Result"];
            				for (var j = 0; j < posts_array.length; j++) {
            					var cur_articleId = posts_array[j]["item"]["articleId"];
            					console.log(j + " " + cur_articleId);
            				}
            			});
           			}
           		}
           	}
        
        	function sendCommentBtn() {
        		setTimeout(sendCommentAll, 0);
        	}
        
        	async function addMenu() {
	            function queryData(requestProcess, data) {
	                return new Promise(function (response) {
	                    $.ajax({
	                        type: "POST",
	                        url: './commentBot_process.jsp',
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
	            
        		var strCafeUrl = document.querySelector("#commentCafeUrl").value;
        		await queryData("getClubId", "cafeUrl=" + strCafeUrl).then(function (requestResult) {
                    if (requestResult["Status"] == "Success") {
                    	var strClubId = requestResult["Result"]["clubid"];
                    	
                        var postsTable = document.querySelector("#comments_queue tbody");
                        
                        var trObj = document.createElement("tr");
                        trObj.setAttribute("class", "comment");

                        var check_td = document.createElement("td");
                        var check_input = document.createElement("input");
                        check_input.setAttribute("type", "checkbox");
                        check_input.setAttribute("class", "checkBox form-check-input");
                        check_td.appendChild(check_input);
                        trObj.appendChild(check_td);

                        var tdObj = document.createElement("td");
                        tdObj.setAttribute("class", "clubid");
                        tdObj.innerText = strClubId;
                        trObj.appendChild(tdObj);

                        tdObj = document.createElement("td");
                        tdObj.setAttribute("class", "menuid");
                        var selectedMenu = document.querySelector("#commentMenus");
                        tdObj.innerText = selectedMenu[selectedMenu.selectedIndex].value;
                        trObj.appendChild(tdObj);

                        tdObj = document.createElement("td");
                        tdObj.setAttribute("class", "comment_text");
                        tdObj.innerText = document.querySelector("#commentText").value;
                        trObj.appendChild(tdObj);

                        postsTable.appendChild(trObj);
                    }
            	});
        	}
        	
        	function addMenuBtn() {
        		setTimeout(addMenu, 0);
        	}
        
	        function checkAllCommentItems() {
	            var checkBoxes = document.querySelectorAll("#comments_queue .comment .checkBox");
	            for (var i=0; i<checkBoxes.length; i++) {
	                checkBoxes[i].checked = true;
	            }
	        }
        
	        async function CommentBot_loadMenus() {
	            function queryData(requestProcess, data) {
	                return new Promise(function (response) {
	                    $.ajax({
	                        type: "POST",
	                        url: './commentBot_process.jsp',
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
	            
	            var menuOptions = document.querySelectorAll("#commentMenus>option");
	            for (var i=0; i<menuOptions.length; i++) {
	                var currentNode = menuOptions[i];
	                currentNode.parentNode.removeChild(currentNode);
	            }
	            
	            var menusObject = document.getElementById("commentMenus");
	            
	            var cafeUrl = document.getElementById("commentCafeUrl").value;
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
	        
	        function CommentBot_btnLoadMenus() {
	            setTimeout(CommentBot_loadMenus, 0);
	        }
        </script>
    </body>
</html>