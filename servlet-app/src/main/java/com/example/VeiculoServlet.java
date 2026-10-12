package com.example;

import java.io.IOException;
import java.sql.SQLException;

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
        int idCliente = WebSupport.clienteId(request, response);
        if (idCliente < 0) {
            return;
        }
        try {
            request.setAttribute("veiculos", LavaRapidoRepository.listarVeiculos(idCliente));
            request.getRequestDispatcher("/veiculos.jsp").forward(request, response);
        } catch (SQLException exception) {
            WebSupport.erroBanco(request, response, exception);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int idCliente = WebSupport.clienteId(request, response);
        if (idCliente < 0) {
            return;
        }
        String acao = WebSupport.campo(request, "acao");
        try {
            if ("remover".equals(acao)) {
                Integer id = WebSupport.inteiro(WebSupport.campo(request, "idVeiculo"));
                if (id == null || !LavaRapidoRepository.removerVeiculo(idCliente, id)) {
                    response.setStatus(HttpServletResponse.SC_CONFLICT);
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
                    request.setAttribute("erro", "Informe placa, marca e modelo dentro dos limites indicados.");
                    doGet(request, response);
                    return;
                }
                LavaRapidoRepository.adicionarVeiculo(idCliente, placa, marca, modelo, cor);
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
