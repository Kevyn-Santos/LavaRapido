package com.splash.web.servlet;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/health")
public class Health extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response){
        response.setStatus(200);
    }

}
