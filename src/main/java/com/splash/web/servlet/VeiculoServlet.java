package com.splash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;

import com.splash.web.db.DAOVeiculo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/veiculos")
public class VeiculoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int clienteId = WebSupport.clienteId(request, response);
        if (clienteId < 0) {
            return;
        }
        try {
            request.setAttribute("veiculos", new DAOVeiculo().listarPorCliente(clienteId));
            request.getRequestDispatcher("/WEB-INF/views/veiculos.jsp").forward(request, response);
        } catch (SQLException exception) {
            WebSupport.erroBanco(request, response, exception);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int clienteId = WebSupport.clienteId(request, response);
        if (clienteId < 0) {
            return;
        }
        DAOVeiculo daoVeiculo = new DAOVeiculo();
        String acao = WebSupport.campo(request, "acao");
        try {
            if ("remover".equals(acao)) {
                Integer idVeiculo = WebSupport.inteiro(WebSupport.campo(request, "idVeiculo"));
                if (idVeiculo == null || !daoVeiculo.remover(clienteId, idVeiculo)) {
                    request.setAttribute("erro", "Veículo não encontrado ou vinculado a um agendamento.");
                    doGet(request, response);
                    return;
                }
            } else if ("adicionar".equals(acao)) {
                String placa = WebSupport.campo(request, "placa").toUpperCase();
                String marca = WebSupport.campo(request, "marca");
                String modelo = WebSupport.campo(request, "modelo");
                String cor = WebSupport.campo(request, "cor");
                if (!WebSupport.preenchidos(placa, marca, modelo) || placa.length() > 10
                        || marca.length() > 60 || modelo.length() > 60 || cor.length() > 30) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    request.setAttribute("erro", "Informe placa, marca e modelo com os limites indicados.");
                    doGet(request, response);
                    return;
                }
                daoVeiculo.inserir(clienteId, placa, marca, modelo, cor);
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Ação inválida.");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/veiculos");
        } catch (SQLException exception) {
            if (exception.getSQLState() != null && exception.getSQLState().startsWith("23")) {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                request.setAttribute("erro", "A placa já está cadastrada ou o veículo possui agendamentos.");
                doGet(request, response);
                return;
            }
            WebSupport.erroBanco(request, response, exception);
        }
    }
}
