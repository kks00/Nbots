<%@ page contentType = "text/html;charset=utf-8" %>

<%@ page import="java.util.*"%>

<%@ include file="util.jsp"%>

<html>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous"></script>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Nanum+Gothic&display=swap" rel="stylesheet">
    
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <%
            if (session.getAttribute("NaverLoginInfo") == null) {
                response.sendRedirect("./login/login.jsp");
            } else {
                Map<String, String> naverCookieData = (Map<String, String>)session.getAttribute("NaverLoginInfo");
    
                Response responseProfile = Jsoup.connect("https://nid.naver.com/user2/help/naverProfile")
                    .cookies(naverCookieData)
                    .method(Method.GET)
                    .ignoreContentType(true)
                    .ignoreHttpErrors(true)
                    .execute();

                Document docProfile = responseProfile.parse();
                String profile_photo = docProfile.select(".profile_photo #imgThumb").attr("src");
                String nickName = docProfile.select("#inpNickname").attr("value");
    %>
    <body style="font-family: 'Nanum Gothic', sans-serif;">
        <div class="modal fade" id="progressModal" tabindex="-1" aria-labelledby="progressModalLabel" style="display: none;" aria-hidden="true">
          <div class="modal-dialog">
            <div class="modal-content">
              <div class="modal-header">
                <h5 class="modal-title" id="progressModalLabel">대기중</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
              </div>
              <div class="modal-body" id="progressModalBody">
                <div class="progress">
                  <div class="progress-bar progress-bar-striped progress-bar-animated" role="progressbar" style="width: 0%;" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100">0/0</div>
                </div>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
              </div>
            </div>
          </div>
        </div>
        
        <main class="bg-light">
            <div class="d-flex align-items-start bg-light w-100 h-100">
                <div class="d-flex flex-column p-3 text-white bg-dark h-100" style="width: 280px; position: fixed;">
                    <a href="./" class="d-flex align-items-center mb-3 mb-md-0 me-md-auto text-white text-decoration-none">
                      <img class="bi me-2" width="40" height="40" src="./images/naver.png">
                      <span class="fs-4">NBots</span>
                    </a>

                    <hr>

                    <ul class="nav nav-pills flex-column mb-auto" role="tablist">
                      <li class="nav-item" role="presentation">
                        <a href="#" class="nav-link text-white active" data-bs-toggle="tab" data-bs-target="#postBotTab" role="tab" aria-controls="postBotTab" aria-selected="true">
                          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-file-earmark-arrow-up" viewBox="0 0 16 16" style="margin-right: 10px;">
                              <path d="M8.5 11.5a.5.5 0 0 1-1 0V7.707L6.354 8.854a.5.5 0 1 1-.708-.708l2-2a.5.5 0 0 1 .708 0l2 2a.5.5 0 0 1-.708.708L8.5 7.707V11.5z"/>
                              <path d="M14 14V4.5L9.5 0H4a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2zM9.5 3A1.5 1.5 0 0 0 11 4.5h2V14a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h5.5v2z"/>
                          </svg>
                          Cafe Post Bot
                        </a>
                      </li>
                      <li class="nav-item" role="presentation">
                        <a href="#" class="nav-link text-white" data-bs-toggle="tab" data-bs-target="#buddyBotTab" role="tab" aria-controls="buddyBotTab" aria-selected="false">
                          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-person-plus" viewBox="0 0 16 16" style="margin-right: 10px;">
                              <path d="M6 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6zm2-3a2 2 0 1 1-4 0 2 2 0 0 1 4 0zm4 8c0 1-1 1-1 1H1s-1 0-1-1 1-4 6-4 6 3 6 4zm-1-.004c-.001-.246-.154-.986-.832-1.664C9.516 10.68 8.289 10 6 10c-2.29 0-3.516.68-4.168 1.332-.678.678-.83 1.418-.832 1.664h10z"/>
                              <path fill-rule="evenodd" d="M13.5 5a.5.5 0 0 1 .5.5V7h1.5a.5.5 0 0 1 0 1H14v1.5a.5.5 0 0 1-1 0V8h-1.5a.5.5 0 0 1 0-1H13V5.5a.5.5 0 0 1 .5-.5z"/>
                          </svg>
                          Blog Buddy Bot
                        </a>
                      </li>
                      <li class="nav-item" role="presentation">
                        <a href="#" class="nav-link text-white" data-bs-toggle="tab" data-bs-target="#reactionBotTab" role="tab" aria-controls="reactionBotTab" aria-selected="false">
                          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-people" viewBox="0 0 16 16" style="margin-right: 10px;">
                            <path d="M15 14s1 0 1-1-1-4-5-4-5 3-5 4 1 1 1 1h8zm-7.978-1A.261.261 0 0 1 7 12.996c.001-.264.167-1.03.76-1.72C8.312 10.629 9.282 10 11 10c1.717 0 2.687.63 3.24 1.276.593.69.758 1.457.76 1.72l-.008.002a.274.274 0 0 1-.014.002H7.022zM11 7a2 2 0 1 0 0-4 2 2 0 0 0 0 4zm3-2a3 3 0 1 1-6 0 3 3 0 0 1 6 0zM6.936 9.28a5.88 5.88 0 0 0-1.23-.247A7.35 7.35 0 0 0 5 9c-4 0-5 3-5 4 0 .667.333 1 1 1h4.216A2.238 2.238 0 0 1 5 13c0-1.01.377-2.042 1.09-2.904.243-.294.526-.569.846-.816zM4.92 10A5.493 5.493 0 0 0 4 13H1c0-.26.164-1.03.76-1.724.545-.636 1.492-1.256 3.16-1.275zM1.5 5.5a3 3 0 1 1 6 0 3 3 0 0 1-6 0zm3-2a2 2 0 1 0 0 4 2 2 0 0 0 0-4z"/>
                          </svg>
                          Blog Reaction Bot
                        </a>
                      </li>  
                      <li class="nav-item" role="presentation">
                        <a href="#" class="nav-link text-white" data-bs-toggle="tab" data-bs-target="#commentBotTab" role="tab" aria-controls="commentBotTab" aria-selected="false">
							<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-pencil-square" viewBox="0 0 16 16" style="margin-right: 13px;">
							  <path d="M15.502 1.94a.5.5 0 0 1 0 .706L14.459 3.69l-2-2L13.502.646a.5.5 0 0 1 .707 0l1.293 1.293zm-1.75 2.456-2-2L4.939 9.21a.5.5 0 0 0-.121.196l-.805 2.414a.25.25 0 0 0 .316.316l2.414-.805a.5.5 0 0 0 .196-.12l6.813-6.814z"/>
							  <path fill-rule="evenodd" d="M1 13.5A1.5 1.5 0 0 0 2.5 15h11a1.5 1.5 0 0 0 1.5-1.5v-6a.5.5 0 0 0-1 0v6a.5.5 0 0 1-.5.5h-11a.5.5 0 0 1-.5-.5v-11a.5.5 0 0 1 .5-.5H9a.5.5 0 0 0 0-1H2.5A1.5 1.5 0 0 0 1 2.5v11z"/>
							</svg>
                        	Comment Bot
                        </a>
                      </li>  
                    </ul>

                    <hr>

                    <div class="dropdown">
                      <a href="#" class="d-flex align-items-center text-white text-decoration-none dropdown-toggle" id="dropdownUser1" data-bs-toggle="dropdown" aria-expanded="false">
                        <img src="<%=profile_photo%>" alt="" width="32" height="32" class="rounded-circle me-2">
                        <strong><%=nickName%></strong>
                      </a>
                      <ul class="dropdown-menu dropdown-menu-dark text-small shadow" aria-labelledby="dropdownUser1" style="">
                        <li>
                            <a class="dropdown-item" href="./login/logout.jsp">
                                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-box-arrow-left" viewBox="0 0 16 16" style="margin-right: 10px;">
                                  <path fill-rule="evenodd" d="M6 12.5a.5.5 0 0 0 .5.5h8a.5.5 0 0 0 .5-.5v-9a.5.5 0 0 0-.5-.5h-8a.5.5 0 0 0-.5.5v2a.5.5 0 0 1-1 0v-2A1.5 1.5 0 0 1 6.5 2h8A1.5 1.5 0 0 1 16 3.5v9a1.5 1.5 0 0 1-1.5 1.5h-8A1.5 1.5 0 0 1 5 12.5v-2a.5.5 0 0 1 1 0v2z"/>
                                  <path fill-rule="evenodd" d="M.146 8.354a.5.5 0 0 1 0-.708l3-3a.5.5 0 1 1 .708.708L1.707 7.5H10.5a.5.5 0 0 1 0 1H1.707l2.147 2.146a.5.5 0 0 1-.708.708l-3-3z"/>
                                </svg>
                                로그아웃
                            </a>
                        </li>
                      </ul>
                    </div>                    
                </div>
                
                <div class="tab-content" id="contentsTab" style="margin-left: 280px;">
                    <div class="tab-pane fade active show" id="postBotTab" role="tabpanel" aria-labelledby="postBot-tab">
                        <jsp:include page="postBot.jsp"/>
                    </div>
                    <div class="tab-pane fade" id="buddyBotTab" role="tabpanel" aria-labelledby="buddyBot-tab">
                        <jsp:include page="buddyBot.jsp"/>
                    </div>
                    <div class="tab-pane fade" id="reactionBotTab" role="tabpanel" aria-labelledby="reactionBot-tab">
                        <jsp:include page="reactionBot.jsp"/>
                    </div>
                    <div class="tab-pane fade" id="commentBotTab" role="tabpanel" aria-labelledby="commentBotTab">
                        <jsp:include page="commentBot.jsp"/>
                    </div>
                </div>
            </div>
        </main>
    </body>
    <%
        }
    %>
</html>