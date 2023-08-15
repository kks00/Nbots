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

        if (requestProcess.equals("getClubId")) {
                String cafeUrl = request.getParameter("cafeUrl");

                naverCookieData = (Map<String, String>)session.getAttribute("NaverLoginInfo");

                Response responseCafeMain = Jsoup.connect("https://cafe.naver.com/" + cafeUrl)
                    .cookies(naverCookieData)
                    .method(Method.GET)
                    .ignoreContentType(true)
                    .ignoreHttpErrors(true)
                    .execute();

                String clubid = parseString(responseCafeMain.parse().toString(), "var g_sClubId = \"", "\";").get(0);

                JSONObject returnObject = new JSONObject();
                returnObject.put("clubid", clubid);
                printObject.put("Result", returnObject);
        } else if (requestProcess.equals("getTempArticles")) {
            String clubid = request.getParameter("clubid");

            naverCookieData = (Map<String, String>)session.getAttribute("NaverLoginInfo");

            Response responseTmpArticles = Jsoup.connect("https://apis.naver.com/cafe-web/cafe-editor-api/v1/cafes/" + clubid + "/temporary-articles")
                .cookies(naverCookieData)
                .method(Method.GET)
                .ignoreContentType(true)
                .ignoreHttpErrors(true)
                .execute();

            JSONArray returnArray = new JSONArray();

            JSONObject responseObject = new JSONObject(responseTmpArticles.parse().select("body").text());
            JSONArray tmpArticlesArr = responseObject.getJSONObject("result").getJSONArray("temporaryArticles");
            for (int i=0; i<tmpArticlesArr.length(); i++) {
                JSONObject currentArticle = (JSONObject)tmpArticlesArr.get(i);
                Integer temporaryArticleId = currentArticle.getInt("temporaryArticleId");
                String subject = currentArticle.getString("subject");

                JSONObject newObject = new JSONObject();
                newObject.put("ArticleId", temporaryArticleId);
                newObject.put("subject", subject);

                returnArray.put(returnArray.length(), newObject);
            }

            printObject.put("Result", returnArray);
        } else if (requestProcess.equals("getMenus")) {
            String clubid = request.getParameter("clubid");

            naverCookieData = (Map<String, String>)session.getAttribute("NaverLoginInfo");

            Response responseMenus = Jsoup.connect("https://apis.naver.com/cafe-web/cafe-cafeinfo-api/v1.0/cafes/" + clubid + "/editor/menus")
                .header("origin", "https://cafe.naver.com")
                .header("referer", "https://cafe.naver.com/ca-fe/cafes/" + clubid + "/articles/write?boardType=L")
                .header("x-cafe-product", "pc")

                .cookies(naverCookieData)

                .method(Method.GET)
                .ignoreContentType(true)
                .ignoreHttpErrors(true)
                .execute();

            JSONArray returnArray = new JSONArray();

            JSONObject menusObject = new JSONObject(responseMenus.parse().select("body").text());
            JSONArray resultsArray = menusObject.getJSONArray("result");
            for (int i=0; i<resultsArray.length(); i++) {
                JSONObject resultObject = (JSONObject)resultsArray.get(i);
                Integer menuId = resultObject.getInt("menuId");
                String menuName = resultObject.getString("menuName");

                JSONObject newObject = new JSONObject();
                newObject.put("menuId", menuId);
                newObject.put("menuName", menuName);

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