<%@ page contentType = "application/json;charset=utf-8" %>

<%@ page import="java.util.*"%>

<%@ include file="util.jsp"%>

<%
    request.setCharacterEncoding("utf-8");

    String tempClubId = request.getParameter("tempClubId");
    String temporaryArticleId = request.getParameter("temporaryArticleId");
    String targetClubId = request.getParameter("targetClubId");
    String menuId = request.getParameter("menuId");

    Map<String, String> naverCookieData = (Map<String, String>)session.getAttribute("NaverLoginInfo");
    Response responseArticle = Jsoup.connect("https://apis.naver.com/cafe-web/cafe-editor-api/v1.0/cafes/" + tempClubId + "/temporary-articles/" + temporaryArticleId + "?from=pc")
        .header("origin", "https://cafe.naver.com")
        .header("referer", "https://cafe.naver.com/ca-fe/cafes/" + tempClubId + "/articles/write?boardType=L")
        .header("x-cafe-product", "pc")

        .cookies(naverCookieData)

        .method(Method.GET)
        .ignoreContentType(true)
        .ignoreHttpErrors(true)
        .execute();

    JSONObject responseObject = new JSONObject(responseArticle.parse().select("body").text());

    JSONObject articleObject = responseObject.getJSONObject("result").getJSONObject("article");
    String strSubject = articleObject.getString("subject");
    String strContentJson = articleObject.getString("contentJson");

    JSONObject optionsObject = responseObject.getJSONObject("result").getJSONObject("options");
    Boolean boolOpen = optionsObject.getBoolean("open");
    Boolean boolNaverOpen = optionsObject.getBoolean("naverOpen");
    Boolean boolExternalOpen = optionsObject.getBoolean("externalOpen");
    Boolean boolEnableComment = optionsObject.getBoolean("enableComment");
    Boolean boolEnableScrap = optionsObject.getBoolean("enableScrap");
    Boolean boolEnableCopy = optionsObject.getBoolean("enableCopy");
    Boolean boolUseAutoSource = optionsObject.getBoolean("useAutoSource");

    JSONObject articleJson = new JSONObject();
    articleJson.put("cafeId", targetClubId);
    articleJson.put("cclTypes", new JSONArray());
    articleJson.put("contentJson", strContentJson);
    articleJson.put("editorVersion", 4);
    articleJson.put("enableComment", boolEnableComment);
    articleJson.put("enableCopy", boolEnableCopy);
    articleJson.put("enableScrap", boolEnableScrap);
    articleJson.put("externalOpen", boolExternalOpen);
    articleJson.put("from", "pc");
    articleJson.put("menuId", Integer.parseInt(menuId));
    articleJson.put("naverOpen", boolNaverOpen);
    articleJson.put("open", boolOpen);
    articleJson.put("parentId", 0);
    articleJson.put("subject", strSubject);
    articleJson.put("tagList", new JSONArray());
    articleJson.put("useAutoSource", boolUseAutoSource);
    articleJson.put("useCcl", false);

    JSONObject postJson = new JSONObject();
    postJson.put("article", articleJson);

    if (responseObject.getJSONObject("result").has("personalTradeDirect")) {
        JSONObject tempTradeObject = responseObject.getJSONObject("result").getJSONObject("personalTradeDirect");
            
        JSONObject personalTradeDirect = new JSONObject();
        personalTradeDirect.put("category1", tempTradeObject.getString("category1"));
        personalTradeDirect.put("category2", tempTradeObject.getString("category2"));
        personalTradeDirect.put("category3", tempTradeObject.getString("category3"));
        personalTradeDirect.put("cost", Integer.parseInt(tempTradeObject.getString("cost")));
        personalTradeDirect.put("deliveryTypes", tempTradeObject.getJSONArray("deliveryTypes"));
        personalTradeDirect.put("productCondition", tempTradeObject.getString("productCondition"));
            
        if (tempTradeObject.has("tradeRegions")) {
            personalTradeDirect.put("tradeRegions", tempTradeObject.getJSONArray("tradeRegions"));
        } else {
            JSONArray tradeRegions = new JSONArray();
            personalTradeDirect.put("tradeRegions", tradeRegions);
        }
            
        personalTradeDirect.put("watermark", tempTradeObject.getBoolean("watermark"));
            
        if (tempTradeObject.has("paymentCorp")) {
            personalTradeDirect.put("paymentCorp", tempTradeObject.getString("paymentCorp"));
        } else {
            personalTradeDirect.put("paymentCorp", "NONE");
        }
            
        personalTradeDirect.put("npayRemit", tempTradeObject.getBoolean("npayRemit"));
            
        personalTradeDirect.put("quantity", 0);
        personalTradeDirect.put("expireDate", "Invalid date");
            
        if (tempTradeObject.has("allowedPayments")) {
            personalTradeDirect.put("allowedPayments", tempTradeObject.getJSONArray("allowedPayments"));
        } else {
            JSONArray tradeRegions = new JSONArray();
            personalTradeDirect.put("allowedPayments", tradeRegions);
        }
            
        personalTradeDirect.put("menuId", Integer.parseInt(tempTradeObject.getString("menuId")));
        personalTradeDirect.put("title", strSubject);
        personalTradeDirect.put("specification", strSubject);
        personalTradeDirect.put("openPhoneNo", tempTradeObject.getBoolean("openPhoneNo"));
        personalTradeDirect.put("useOtn", tempTradeObject.getBoolean("useOtn"));
        personalTradeDirect.put("channelNo", "");
        personalTradeDirect.put("channelProductNo", "");
        personalTradeDirect.put("storefarmImgUrl", "");
            
        JSONArray uploadPhoto = new JSONArray();
        personalTradeDirect.put("uploadPhoto", uploadPhoto);
            
        postJson.put("personalTradeDirect", personalTradeDirect);
            
        postJson.put("tradeArticle", true);
    }

    naverCookieData = (Map<String, String>)session.getAttribute("NaverLoginInfo");
    Response responsePost = Jsoup.connect("https://apis.naver.com/cafe-web/cafe-editor-api/v1.0/cafes/" + targetClubId + "/menus/" + menuId + "/articles")
        .header("origin", "https://cafe.naver.com")
        .header("referer", "https://cafe.naver.com/ca-fe/cafes/" + targetClubId + "/menus/" + menuId + "/articles/write?boardType=L")
        .header("x-cafe-product", "pc")
        .header("content-type", "application/json;charset=UTF-8")

        .requestBody(postJson.toString())
        .cookies(naverCookieData)

        .method(Method.POST)
        .ignoreContentType(true)
        .ignoreHttpErrors(true)
        .execute();

    out.print(responsePost.parse().select("body").text());
%>
