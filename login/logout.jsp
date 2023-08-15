<%@ page contentType = "text/html;charset=utf-8" %>
<html>
    <%
        session.invalidate();
        response.sendRedirect("./login.jsp");
    %>
</html>