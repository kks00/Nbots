<%@ page import="java.util.*"%>
<%@ page import="java.io.FileReader"%>
<%@ page import="java.io.BufferedReader"%>

<%@ page import="javax.script.*"%>

<%!
    Object shellJS(String scriptFile, String functionName, String[] paramStr) {
        Object result = null;
        ScriptEngineManager manager = new ScriptEngineManager();
        ScriptEngine engine = manager.getEngineByName("JavaScript");
        try {
            String filePath = getServletContext().getRealPath("")  + scriptFile;
            BufferedReader scriptReader = new BufferedReader(new FileReader(filePath));
            engine.eval(scriptReader);
            Invocable invoker = (Invocable)engine;
            result = invoker.invokeFunction(functionName, paramStr);
        } catch (Exception e) {
            return e;
        }
        return result;
    }
%>