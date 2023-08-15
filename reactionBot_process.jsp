<%@ page contentType = "application/json;charset=utf-8" %>

<%@ page import="java.util.*"%>

<%@ include file="util.jsp"%>

<%
    request.setCharacterEncoding("utf-8");

    try {
        String requestProcess = request.getParameter("process");

        JSONObject printObject = new JSONObject();
        printObject.put("Status", "Success");
        
        Map<String, String> naverCookieData = null;

        if (requestProcess.equals("getPostList")) {
            String bloggerId = request.getParameter("bloggerId");
            Integer count = Integer.parseInt(request.getParameter("count"));
            
            JSONArray returnArray = new JSONArray();
            
            Integer currentPage = 0;
            Integer totalCount = 0;
            Integer processCount = 0;
            
            Boolean hasMore = true;
            while (hasMore) {
                currentPage++;
                
                naverCookieData = (Map<String, String>)session.getAttribute("NaverLoginInfo");

                Response postListResponse = Jsoup.connect("https://blog.naver.com/PostTitleListAsync.naver?blogId=" + bloggerId + "&viewdate=&currentPage=" + currentPage.toString() + "&categoryNo=0&parentCategoryNo=0&countPerPage=30")
                    .cookies(naverCookieData)
                    .method(Method.GET)
                    .ignoreContentType(true)
                    .ignoreHttpErrors(true)
                    .execute();

                JSONObject postListJSON = new JSONObject(postListResponse.parse().select("body").text());
                
                totalCount = Integer.parseInt(postListJSON.getString("totalCount"));
                
                JSONArray postListArray = postListJSON.getJSONArray("postList");
                for (int i=0; i<postListArray.length(); i++) {
                    if ((processCount >= count) || (processCount >= totalCount)) {
                        hasMore = false;
                        break;
                    } else {
                        returnArray.put(returnArray.length(), postListArray.get(i));
                        processCount++;
                    }
                }
            }
            
            printObject.put("Result", returnArray);
        } else if (requestProcess.equals("getBuddyList")) {
            JSONArray returnArray = new JSONArray();
            
            Boolean hasMore = true;
            Integer currentPage = 1;
            while (hasMore) {
                naverCookieData = (Map<String, String>)session.getAttribute("NaverLoginInfo");

                Response buddyListResponse = Jsoup.connect("https://section.blog.naver.com/ajax/BuddyList.naver?countPerPage=8&groupId=-1&page=" + currentPage.toString() + "&searchText=&type=1")
                    .header("referer", "https://section.blog.naver.com/BlogHome.naver")
                    .cookies(naverCookieData)
                    .method(Method.GET)
                    .ignoreContentType(true)
                    .ignoreHttpErrors(true)
                    .execute();

                String responseString = buddyListResponse.parse().select("body").text();
                responseString = responseString.substring((")]}', ").length());

                JSONObject buddyListJSON = new JSONObject(responseString);
                
                if (currentPage == buddyListJSON.getJSONObject("result").getInt("totalPage"))
                    hasMore = false;
                else
                    currentPage++;
                    
                JSONArray buddyListArray = buddyListJSON.getJSONObject("result").getJSONArray("list");
                for (int i=0; i<buddyListArray.length(); i++) {
                    returnArray.put(returnArray.length(), buddyListArray.get(i));
                }
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