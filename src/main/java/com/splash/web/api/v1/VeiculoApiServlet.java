package com.splash.web.api.v1;

import java.io.IOException;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * <pre>
 * GET    /api/v1/veiculos      -> [{id, placa, marca, modelo, cor}]
 * POST   /api/v1/veiculos      {placa, marca, modelo, cor} -> 201
 * DELETE /api/v1/veiculos/{id} -> 204
 * </pre>
 *
 * TODO: implementar usando DAOVeiculo. Ver miscelaneous/analise-app-mobile.md, seção 3.5.
 */
@WebServlet("/api/v1/veiculos/*")
public class VeiculoApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // TODO: DAOVeiculo.listarPorCliente(idCliente)
        response.sendError(HttpServletResponse.SC_NOT_IMPLEMENTED);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // TODO: DAOVeiculo.inserir(idCliente, placa, marca, modelo, cor)
        response.sendError(HttpServletResponse.SC_NOT_IMPLEMENTED);
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // TODO: DAOVeiculo.remover(idCliente, id) com o id lido do pathInfo (/{id})
        response.sendError(HttpServletResponse.SC_NOT_IMPLEMENTED);
    }
}
