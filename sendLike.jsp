<%@ page contentType = "text/plain;charset=utf-8" %>

<%@ page import="java.util.*"%>
<%@ page import="java.net.URLEncoder"%>

<%@ include file="util.jsp"%>

<%
    request.setCharacterEncoding("utf-8");

    String bloggerId = request.getParameter("bloggerId");
    String postNum = request.getParameter("postNum");

    Map<String, String> naverCookieData = (Map<String, String>)session.getAttribute("NaverLoginInfo");

    String guestToken = "";
    String timestamp = "";

    try {
        String queryUrl = "https://blog.like.naver.com/v1/search/contents?suppress_response_codes=true&callback=&q=" + URLEncoder.encode("BLOG[" + bloggerId + "_" + postNum + "]") + "&isDuplication=true&cssIds=BASIC_PC_SSL%2CBLOG_PC_SSL&_=";
        Response queryResponse = Jsoup.connect(queryUrl)
            .userAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.71 Safari/537.36")
            .header("referer", "https://blog.naver.com/PostView.naver")

            .cookies(naverCookieData)

            .method(Method.GET)
            .ignoreContentType(true)
            .ignoreHttpErrors(true)
            .execute();

        String responseJSON = queryResponse.parse().select("body").text();
        responseJSON = parseString(responseJSON, "/**/(", ");").get(0);
        JSONObject queryJSON = new JSONObject(responseJSON);
        guestToken = queryJSON.getString("guestToken");
        timestamp = queryJSON.getString("timestamp");
    } catch (Exception e) {
        out.print(e);
    }

    try {
        String sendUrl = "https://blog.like.naver.com/v1/services/BLOG/contents/" + URLEncoder.encode(bloggerId + "_" + postNum);
        String sendParam = "?suppress_response_codes=true&_method=POST&callback=&displayId=BLOG&reactionType=like&categoryId=post&guestToken=" + URLEncoder.encode(guestToken) + "&timestamp=" + URLEncoder.encode(timestamp) + "&_ch=pcw&isDuplication=true&lang=ko&countType=default&count=1&history=&runtimeStatus=&isPostTimeline=false&_=";

        naverCookieData = (Map<String, String>)session.getAttribute("NaverLoginInfo");
        Response sendResponse = Jsoup.connect(sendUrl.concat(sendParam))
            .userAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.71 Safari/537.36")

            .cookies(naverCookieData)

            .method(Method.GET)
            .ignoreContentType(true)
            .execute();

        JSONObject responseJSON = new JSONObject(sendResponse.parse().select("body").text());
        if (responseJSON.getString("message").equals("좋아요가 되었습니다.")) {
            out.print("SUCCESS");
        } else {
            out.print(responseJSON.getString("message"));
        }
    }  catch (Exception e) {
        out.print(e);
    }
%>