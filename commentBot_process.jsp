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
        } else if (requestProcess.equals("getArticles")) {
	        String clubid = request.getParameter("clubid");
	        String menuid = request.getParameter("menuid");
	        Integer count = Integer.parseInt(request.getParameter("count"));
	        
	        naverCookieData = (Map<String, String>)session.getAttribute("NaverLoginInfo");
	        
	        JSONArray returnArray = new JSONArray();
	        Integer processCount = 0;
	        Integer pageNum = 0;
	        Boolean hasMore = true;
	        
	        while (hasMore) {
	        	pageNum++;
	        	
		        Response responseArticles = Jsoup.connect("https://apis.naver.com/cafe-web/cafe2/ArticleList.json")
		                .header("origin", "https://m.cafe.naver.com")
		                .header("referer", "https://m.cafe.naver.com/ca-fe/web/cafes/" + clubid + "/menus/" + menuid)
		                .header("x-cafe-product", "mweb")
		                
		                .data("search.clubid", clubid)
		                .data("search.queryType", "lastArticle")
		                .data("search.menuid", menuid)
		                .data("search.page", Integer.toString(pageNum))
		                .data("search.perPage", "A")
		                .data("ad", "true")
		                .data("uuid", "")
		                .data("adUnit", "MW_CAFE_ARTICLE_LIST_RS")
		
		                .cookies(naverCookieData)
		
		                .method(Method.GET)
		                .ignoreContentType(true)
		                .ignoreHttpErrors(true)
		                .execute();
		
		        JSONObject ArticlesObject = new JSONObject(responseArticles.parse().select("body").text());
		        
		        if (ArticlesObject.getJSONObject("message").getString("status").equals("200")) {
		        	JSONArray ArticleListArr = ArticlesObject.getJSONObject("message").getJSONObject("result").getJSONArray("articleList");
		        	for (int i = 0; i < ArticleListArr.length(); i++) {
		        		if (processCount >= count) {
		        			hasMore = false;
		        			break;
		        		}
		        		
		        		JSONObject curArticleObject = (JSONObject)ArticleListArr.get(i);
		        		if (curArticleObject.getString("type").equals("ARTICLE")) {
			        		returnArray.put(returnArray.length(), curArticleObject);
			        		processCount++;
		        		}
		        	}
		        	
		        	if (ArticlesObject.getJSONObject("message").getJSONObject("result").getBoolean("hasNext") == false)
		        		break;
		        } else {
		        	break;
		        }
	        }
	        printObject.put("Result", returnArray);
	    } else if (requestProcess.equals("isRepliedPost")) {
	    	String clubid = request.getParameter("clubid");
	        String articleId = request.getParameter("articleId");
	        String count = request.getParameter("count");
	        
	        naverCookieData = (Map<String, String>)session.getAttribute("NaverLoginInfo");
	        
	        Response responseMyActivity = Jsoup.connect("https://cafe.naver.com/MyCafeMyActivityAjax.nhn")                
	                .data("clubid", clubid)
	
	                .cookies(naverCookieData)
	
	                .method(Method.GET)
	                .ignoreContentType(true)
	                .ignoreHttpErrors(true)
	                .execute();
	        
	        String memberKey = parseString(responseMyActivity.parse().html(), "members/", "?").get(0);
	        
	        Response responseArticles = Jsoup.connect("https://apis.naver.com/cafe-web/cafe-mobile/CafeMemberProfileCommentList")
	                .header("origin", "https://m.cafe.naver.com")
	                .header("x-cafe-product", "pc")
	                
	                .data("cafeId", clubid)
	                .data("memberKey", memberKey)
	                .data("perPage", count)
	                .data("page", "1")
	                .data("requestFrom", "A")
	
	                .cookies(naverCookieData)
	
	                .method(Method.GET)
	                .ignoreContentType(true)
	                .ignoreHttpErrors(true)
	                .execute();
	        
	        Boolean isFound = false;
	        JSONObject CommentsJSON = new JSONObject(responseArticles.parse().select("body").text());
	        if(CommentsJSON.getJSONObject("message").getString("status").equals("200")) {
	        	JSONArray CommentsArr = CommentsJSON.getJSONObject("message").getJSONObject("result").getJSONArray("comments");
	        	for (int i = 0; i < CommentsArr.length(); i++) {
	        		JSONObject curComment = (JSONObject)CommentsArr.get(i);
	        		if (curComment.getString("articleId").equals(articleId))
	        			isFound = true;
	        	}
	        	printObject.put("Result", isFound);
	        }
	    }
        out.print(printObject.toString());
    }
    catch (Exception e) {
        JSONObject returnObject = new JSONObject();
        returnObject.put("Status", "Error");
        returnObject.put("Exception", e.toString());
        out.print(returnObject);
    }
%>