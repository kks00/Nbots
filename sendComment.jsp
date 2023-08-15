<%@ page contentType = "text/plain;charset=utf-8" %>

<%@ page import="java.util.*"%>
    
<%@ include file="util.jsp"%>

<%
    String bloggerId = request.getParameter("bloggerId");
    String postNum = request.getParameter("postNum");
    String contents = request.getParameter("contents");

    String blogNo = "";
    try {
        String postUrl = "https://blog.naver.com/PostView.naver?blogId=" + bloggerId + "&logNo=" + postNum;
        Document postDoc = Jsoup.connect(postUrl).get();
        blogNo = parseString(postDoc.toString(), "var blogNo = '", "';").get(0);
    } catch (Exception e) {
        out.print(e);
    }

    Map<String, String> naverCookieData = (Map<String, String>)session.getAttribute("NaverLoginInfo");

    String cbox_token = "";
    try {
        Response getTokenResponse = Jsoup.connect("https://apis.naver.com/commentBox/cbox/web_naver_token_jsonp.json")
            .userAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 Edg/92.0.902.84")
            .header("referer", "https://blog.naver.com/PostView.naver")

            .data("ticket", "blog")
            .data("templateId", "default")
            .data("pool", "cbox9")
            .data("_wr", "")
            .data("_callback", "")
            .data("lang", "ko")
            .data("country", "")
            .data("objectId", blogNo + "_201_" + postNum)
            .data("categoryId", "")
            .data("pageSize", "50")
            .data("indexSize", "10")
            .data("groupId", blogNo)
            .data("listType", "OBJECT")
            .data("pageType", "default")
            .data("_", "")

            .cookies(naverCookieData)

            .ignoreContentType(true)
            .ignoreHttpErrors(true)
            .method(Method.GET)
            .execute();

        String responseText = getTokenResponse.parse().select("body").text();
        responseText = parseString(responseText, "(", ");").get(0);
        JSONObject getTokenJSON = new JSONObject(responseText);
        cbox_token = getTokenJSON.getJSONObject("result").getString("cbox_token");
    } catch (Exception e) {
        out.print(e);
    }
    
    try {
        Response writeCommentResponse = Jsoup.connect("https://apis.naver.com/commentBox/cbox/web_naver_create_json.json")
            .userAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 Edg/92.0.902.84")
            .header("origin", "https://blog.naver.com")
            .header("referer", "https://blog.naver.com/PostView.naver")

            .data("ticket", "blog")
            .data("templateId", "default")
            .data("pool", "cbox9")
            .data("_wr", "")
            .data("lang", "ko")
            .data("country", "")
            .data("objectId", blogNo + "_201_" + postNum)
            .data("categoryId", "")
            .data("pageSize", "50")
            .data("indexSize", "10")
            .data("groupId", blogNo)
            .data("listType", "OBJECT")
            .data("pageType", "default")
            .data("clientType", "web-pc")
            .data("objectUrl", "https://blog.naver.com/PostView.naver?blogId=" + bloggerId + "&logNo=" + postNum)
            .data("contents", contents)
            .data("userType", "")
            .data("pick", "false")
            .data("score", "0")
            .data("likeItId", bloggerId + "_" + postNum)
            .data("sort", "NEW")
            .data("secret", "false")
            .data("refresh", "true")
            .data("validateBanWords", "true")
            .data("profileId", "11")
            .data("cbox_token", cbox_token)

            .cookies(naverCookieData)

            .ignoreContentType(true)
            .ignoreHttpErrors(true)
            .method(Method.POST)
            .execute();

        JSONObject responseJSON = new JSONObject(writeCommentResponse.parse().select("body").text());
        String messageStr = responseJSON.getString("message");
        if (messageStr.equals("요청을 성공적으로 처리하였습니다.")) {
            out.print("SUCCESS");
        } else {
            out.print(messageStr);
        }
    } catch (Exception e) {
        out.print(e);
    }
%>