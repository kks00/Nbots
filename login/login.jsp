<%@ page contentType = "text/html;charset=utf-8" %>
<html>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous"></script>
    
    <style>
        html, body {
          height: 100%;
        }

        body {
          display: flex;
          align-items: center;
          padding-top: 40px;
          padding-bottom: 40px;
          background-color: #f5f5f5;
        }

        .form-signin {
          width: 100%;
          max-width: 330px;
          padding: 15px;
          margin: auto;
        }

        .form-signin .checkbox {
          font-weight: 400;
        }

        .form-signin .form-floating:focus-within {
          z-index: 2;
        }

        .form-signin input[type="email"] {
          margin-bottom: -1px;
          border-bottom-right-radius: 0;
          border-bottom-left-radius: 0;
        }

        .form-signin input[type="password"] {
          margin-bottom: 10px;
          border-top-left-radius: 0;
          border-top-right-radius: 0;
        }
        
        .bd-placeholder-img {
            font-size: 1.125rem;
            text-anchor: middle;
            -webkit-user-select: none;
            -moz-user-select: none;
            user-select: none;
        }

        @media (min-width: 768px) {
            .bd-placeholder-img-lg {
              font-size: 3.5rem;
            }
        }
    </style>
    
    <body class="text-center">
        <%
            if (session.getAttribute("NaverLoginInfo") == null) {
        %>
        <main class="form-signin">
          <form action="login_process.jsp" method="post">
            <img class="mb-4" src="../images/naver.png" alt="" width="148" height="148">
            <h1 class="h3 mb-3 fw-normal">NBots</h1>

            <div class="form-floating">
              <input type="text" class="form-control" name="id" placeholder="아이디">
              <label for="floatingInput">아이디</label>
            </div>
            <div class="form-floating">
              <input type="password" class="form-control" name="pw" placeholder="비밀번호">
              <label for="floatingPassword">비밀번호</label>
            </div>
              
            <input class="w-100 btn btn-lg btn-primary" type="submit" value="로그인">
          </form>
        </main>
        <%
            } else {
                response.sendRedirect("../index.jsp");
            }
        %>
    </body>
</html>