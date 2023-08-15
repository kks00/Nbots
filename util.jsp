<%@page import="java.util.*"%>

<%@page import="org.jsoup.Jsoup"%>
<%@page import="org.jsoup.Connection"%>
<%@page import="org.jsoup.Connection.Method"%>
<%@page import="org.jsoup.Connection.Response"%>
<%@page import="org.jsoup.nodes.Document"%>
<%@page import="org.jsoup.nodes.Element"%>
<%@page import="org.jsoup.select.Elements"%>

<%@page import="org.json.*"%>
<%@page import="org.json.JSONObject"%>

<%!
    List<String> parseString(String inputStr, String startStr, String endStr) {
        List<String> result = new ArrayList<String>();
        String strData = inputStr;
        while (true) {
            int startInx = strData.indexOf(startStr);
            if (startInx == -1)
                break;
            strData = strData.substring(startInx + startStr.length(), strData.length());
            int endInx = strData.indexOf(endStr);
            result.add(strData.substring(0, endInx));
            strData = strData.substring(endInx + endStr.length(), strData.length());
        }
        return result;
    }
%>