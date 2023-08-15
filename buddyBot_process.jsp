<%@ page contentType = "application/json;charset=utf-8" %>

<%@ page import="java.util.*"%>

<%@include file="./util.jsp"%>

<%
    request.setCharacterEncoding("utf-8");

    try {
        String requestProcess = request.getParameter("process");

        JSONObject printObject = new JSONObject();
        printObject.put("Status", "Success");
        
        Map<String, String> naverCookieData = null;

        if (requestProcess.equals("getComments")) {
            String bloggerId = request.getParameter("bloggerId");
            String postNo = request.getParameter("postNo");

            String postUrl = "https://blog.naver.com/PostView.naver?blogId=" + bloggerId + "&logNo=" + postNo;
            
            Document postDoc = Jsoup.connect(postUrl).get();
            String blogNo = parseString(postDoc.toString(), "var blogNo = '", "';").get(0);

            Map<String, String> params = new HashMap<String, String>();
            params.put("ticket", "blog");
            params.put("templateId", "default");
            params.put("pool", "cbox9");
            params.put("lang", "ko");
            params.put("objectId", blogNo + "_201_" + postNo);
            params.put("groupId", blogNo);
            params.put("listType", "OBJECT");
            
            naverCookieData = (Map<String, String>)session.getAttribute("NaverLoginInfo");

            Response postResponse = Jsoup.connect("https://apis.naver.com/commentBox/cbox/web_naver_list_jsonp.json")
                .userAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 Edg/92.0.902.84")
                .header("Referer", "https://m.blog.naver.com/CommentList.naver?blogId=" + bloggerId + "&logNo=" + postNo)
                .header("content-type", "application/x-www-form-urlencoded")
                
                .cookies(naverCookieData)
                .data(params)
                
                .ignoreContentType(true)
                .method(Method.POST)
                .execute();

            String responseString = postResponse.parse().toString();

            List<String> commentContents = parseString(responseString, "contents\":\"", "\"");
            List<String> commentUsername = parseString(responseString, "userName\":\"", "\"");
            List<String> commentUserId = parseString(responseString, "profileUserId\":\"", "\"");

            JSONArray returnArray = new JSONArray();
            
            Iterator iterContents = commentContents.iterator();
            Iterator iterUsername = commentUsername.iterator();
            Iterator iterUserId = commentUserId.iterator();
            while (iterContents.hasNext()) {
                String contentsData = (String)iterContents.next();
                String usernameData = (String)iterUsername.next();
                String useridData = (String)iterUserId.next();
                
                if (useridData.equals(""))
                    continue;
                
                JSONObject newObject = new JSONObject();
                newObject.put("userid", useridData);
                newObject.put("username", usernameData);
                newObject.put("contents", contentsData);

                returnArray.put(returnArray.length(), newObject);
            }
            
            printObject.put("Result", returnArray);
        }
        
        out.print(printObject.toString());
    } catch (Exception e) {
        JSONObject returnObject = new JSONObject();
        returnObject.put("Status", "Error");
        returnObject.put("Exception", e.toString());
        out.print(returnObject);
    }
%>