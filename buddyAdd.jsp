<%@ page contentType = "text/plain;charset=utf-8" %>

<%@ page import="java.util.*"%>

<%@ include file="util.jsp"%>
    
<%
    request.setCharacterEncoding("utf-8");

    String bloggerId = request.getParameter("bloggerId");
    String message = request.getParameter("message");

    Map<String, String> naverCookieData = (Map<String, String>)session.getAttribute("NaverLoginInfo");

    String responseText = "";
    Document resultDocument = null;
    try {
        Response buddyAddRequest = Jsoup.connect("https://blog.naver.com/BuddyAdd.naver")
        .userAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 Edg/92.0.902.84")
        .header("origin", "https://blog.naver.com")
        .header("content-type", "application/x-www-form-urlencoded")
        .header("Referer", "https://blog.naver.com/BuddyAdd.naver")

        .cookies(naverCookieData)
            
        .data("blogId", bloggerId)
        .data("relation", "1")
        .data("groupId", "1")
        .data("groupOpen", "true")
        .data("groupName", "")
        .data("message", message)
            
        .ignoreContentType(true)
        .ignoreHttpErrors(true)
        .method(Method.POST)
        .execute();
        
        resultDocument = buddyAddRequest.parse();
        responseText = resultDocument.select("title").text();
    } catch (Exception e) {
        out.print(e);
    }

    if (responseText.equals("네이버 :: 이웃추가 완료")) {
        out.print("SUCCESS");
    } else {
        out.print("FAILED");
    }
%>