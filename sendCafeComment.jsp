<%@ page contentType = "text/plain;charset=utf-8" %>

<%@ page import="java.util.*"%>
    
<%@ include file="util.jsp"%>

<%
	String cafeId = request.getParameter("cafeId");
	String articleId = request.getParameter("articleId");
	String content = request.getParameter("content");
	
	Map<String, String> naverCookieData = (Map<String, String>)session.getAttribute("NaverLoginInfo");
	
    try {
        Response writeCommentResponse = Jsoup.connect("https://apis.naver.com/cafe-web/cafe-mobile/CommentPost.json")
            .userAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 Edg/92.0.902.84")
            .header("origin", "https://cafe.naver.com")
            .header("referer", "https://cafe.naver.com/ca-fe/cafes/" + cafeId + "/articles/" + articleId)

            .data("content", content)
            .data("stickerId", "")
            .data("cafeId", cafeId)
            .data("articleId", articleId)
            .data("requestFrom", "A")

            .cookies(naverCookieData)

            .ignoreContentType(true)
            .ignoreHttpErrors(true)
            .method(Method.POST)
            .execute();

        String responseStr = writeCommentResponse.parse().select("body").text();
        if (responseStr.contains("errorCode") == true) {
        	out.print("ERROR");
        } else {
        	out.print("SUCCESS");
        }
    } catch (Exception e) {
        out.print(e);
    }
%>