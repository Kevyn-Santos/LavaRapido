
package com.splash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;

import com.splash.web.db.DAOVeiculo;
import com.splash.web.model.Validacao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin/veiculos")
public class AdminVeiculoServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        if (WebSupport.colaboradorId(
                request, response, "OPERACIONAL") < 0) {
            return;
        }

        try {
            String acao = WebSupport.campo(request, "acao");

            if (!"salvar".equals(acao)) {
                throw new IllegalArgumentException(
                    "Ação de veículo inválida."
                );
            }

            Integer idCliente = WebSupport.inteiro(
                WebSupport.campo(request, "idCliente")
            );

            Integer idVeiculo = WebSupport.inteiro(
                WebSupport.campo(request, "idVeiculo")
            );

            if (idCliente == null || idCliente <= 0) {
                throw new IllegalArgumentException(
                    "Selecione um cliente válido."
                );
            }

            String placa = Validacao.placa(
                WebSupport.campo(request, "placa")
            );

            String marca = WebSupport.campo(request, "marca");
            String modelo = WebSupport.campo(request, "modelo");
            String cor = WebSupport.campo(request, "cor");

            if (!WebSupport.preenchidos(marca, modelo)
                    || marca.length() > 60
                    || modelo.length() > 60
                    || cor.length() > 30) {
                throw new IllegalArgumentException(
                    "Confira marca, modelo e cor do veículo."
                );
            }

            DAOVeiculo dao = new DAOVeiculo();

            if (idVeiculo == null) {

                dao.inserir(
                    idCliente, placa, marca, modelo, cor
                );

            } else {

                if (idVeiculo <= 0 || !dao.atualizar(
                        idCliente, idVeiculo,
                        placa, marca, modelo, cor)) {

                    throw new IllegalArgumentException(
                        "Veículo não encontrado, inativo ou sem alterações."
                    );
                }
            }

            response.sendRedirect(
                request.getContextPath()
                + "/painel/carros?sucesso=1"
            );

        } catch (IllegalArgumentException exception) {

            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                exception.getMessage()
            );

        } catch (SQLException exception) {

            if (exception.getSQLState() != null
                    && exception.getSQLState().startsWith("23")) {

                response.sendError(
                    HttpServletResponse.SC_CONFLICT,
                    "Placa já cadastrada ou dados duplicados."
                );
                return;
            }

            WebSupport.erroBanco(request, response, exception);
        }
    }
}
