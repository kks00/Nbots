<%@ page contentType = "text/html;charset=utf-8" %>
<html>
    <body>
        <%@page import="java.util.*"%>
        
        <%@include file="runJsScript.jsp"%>
        <%@include file="../util.jsp"%>
        
        <%!
            String getDynamicKey() {
                String resultStr = "";
                try {
                    Document loginPage = Jsoup.connect("https://nid.naver.com/nidlogin.login").get();
                    Elements loginFrm = loginPage.select("#frmNIDLogin");
                    resultStr = loginFrm.select("#dynamicKey").attr("value");
                }
                catch (Exception e) {}
                return resultStr;
            }
        
            String getSessionKeys(String dynamicKey) {
                String resultStr = "";
                try {
                    Document keyPage = Jsoup.connect("https://nid.naver.com/dynamicKey/" + dynamicKey).get();
                    resultStr = keyPage.select("body").text();
                }
                catch (Exception e) {}
                return resultStr;
            }
        
            String getBvsdData(String uuid, String naverId) {
                return "{\"a\":\"" + uuid + "\",\"b\":\"1.3.4\",\"c\":true,\"d\":[{\"i\":\"id\",\"a\":[],\"b\":{\"a\":[\"0," + naverId + "\"],\"b\":0},\"c\":\"\",\"d\":\"" + naverId + "\",\"e\":false,\"f\":false},{\"i\":\"pw\",\"a\":[],\"b\":{\"a\":[\"0,\"],\"b\":0},\"c\":\"\",\"d\":\"\",\"e\":true,\"f\":false}],\"h\":\"1f\",\"i\":{\"a\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 Edg/92.0.902.84\"}}";
            }
        
            String encodeBvsd(String bvsdData) {
                String[] bvsdParam = { bvsdData };
                return (String)shellJS("login/JS/common.js", "compressToEncodedURIComponent", bvsdParam);
            }
        %>
        <%
            if (session.getAttribute("NaverLoginInfo") == null) {
                String naverId = request.getParameter("id");
                String naverPw = request.getParameter("pw");

                String dynamicKey = getDynamicKey();
                String[] session_keys = getSessionKeys(dynamicKey).split(",");
                String sessionkey = session_keys[0];
                String encnm = session_keys[1];
                String evalue = session_keys[2];
                String nvalue = session_keys[3];
                String[] rsaParam = { naverId, naverPw, sessionkey, evalue, nvalue };
                String encpw = (String)shellJS("login/JS/common.js", "createRsaKey", rsaParam);

                String uuid = UUID.randomUUID().toString() + "-0";
                String bvsdParam = "{\"uuid\":\"" + uuid + "\",\"encData\":\"" + encodeBvsd(getBvsdData(uuid, naverId)) + "\"}";

                Map<String, String> params = new HashMap<String, String>();
                params.put("localechange", "");
                params.put("dynamicKey", dynamicKey);
                params.put("encpw", encpw);
                params.put("enctp", "1");
                params.put("svctype", "1");
                params.put("smart_LEVEL", "1");
                params.put("bvsd", bvsdParam);
                params.put("encnm", encnm);
                params.put("locale", "ko_KR");
                params.put("url", "https://www.naver.com");
                params.put("id", "");
                params.put("pw", "");
                if (request.getParameter("captcha_type") != null) {
                    params.put("chptchakey", request.getParameter("chptchakey"));
                    params.put("captcha_type", request.getParameter("captcha_type"));
                    params.put("rcaptchakey", request.getParameter("rcaptchakey"));
                    params.put("captcha", request.getParameter("captcha"));
                    params.put("chptcha", "");
                }

                Response loginResponse = null;
                try {              
                    loginResponse = Jsoup.connect("https://nid.naver.com/nidlogin.login")                  
                        .userAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 Edg/92.0.902.84")
                        .header("Referer", "https://nid.naver.com/nidlogin.login")
                        .header("content-type", "application/x-www-form-urlencoded")
                        .data(params)
                        .method(Method.POST)
                        .execute();
                } catch (Exception e) {
                    out.print(e);
                }

                Document doResultLogin = loginResponse.parse();
                Elements emFrmLogin = doResultLogin.select("form#frmNIDLogin");
                Elements emCaptcha = doResultLogin.select("div.captcha_wrap");
                if (!emCaptcha.isEmpty()) {
                    String chptchakey = "";
                    String captcha_type = "";
                    String rcaptchakey = "";
                    Elements emFrmInputs = emFrmLogin.select("input");
                    Iterator frmInputs = emFrmInputs.iterator();
                    while (frmInputs.hasNext()) {
                        Element currentInput = (Element)frmInputs.next();
                        if (currentInput.attr("id").equals("chptchakey")) {
                            chptchakey = currentInput.attr("value");
                            continue;
                        }
                        if (currentInput.attr("id").equals("captcha_type")) {
                            captcha_type = currentInput.attr("value");
                            continue;
                        }
                        if (currentInput.attr("id").equals("rcaptchakey")) {
                            rcaptchakey = currentInput.attr("value");
                            continue;
                        }
                    }
        %>
        <jsp:forward page="login_captcha.jsp">
            <jsp:param name="id" value="<%=naverId%>"/>
            <jsp:param name="chptchakey" value="<%=chptchakey%>"/>
            <jsp:param name="captcha_type" value="<%=captcha_type%>"/>
            <jsp:param name="rcaptchakey" value="<%=rcaptchakey%>"/>
        </jsp:forward>
        <%      
                } else {
                    Map<String, String> responseCookies = loginResponse.cookies();
                    if (responseCookies.containsKey("NID_AUT")) {
                        session.setAttribute("NaverLoginInfo", (Object)responseCookies);
                    	session.setMaxInactiveInterval(0);
                        response.sendRedirect("../index.jsp");
                    } else {
                        response.sendRedirect("./login.jsp");
                    }
                }
            } else {
                response.sendRedirect("../index.jsp");
            }
        %>
    </body>
</html>