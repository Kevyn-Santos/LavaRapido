package com.splash.web.api.v1;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.stream.Collectors;

import com.splash.web.api.Json;
import com.splash.web.api.dto.NovoVeiculoRequest;
import com.splash.web.db.DAOVeiculo;
import com.splash.web.model.dto.VeiculoView;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;

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

        // cria a DAO de veículos
        DAOVeiculo dao = new DAOVeiculo();
        try {

            // Cria um JsonObject para lidar com as informações enviadas pelo mobile
            String jsonMobile = request.getReader().lines().collect(Collectors.joining());
            JSONObject jsonObject = new JSONObject(jsonMobile);

            // cria uma lista de veículos advindas da DAO "listarPorCliente"
            List<VeiculoView> veiculos = dao.listarPorCliente(jsonObject.getInt("idcliente"));

            for(VeiculoView item:veiculos) { // Itera sobre cada ítem da lista

                // Adiciona as infomações da lista na DTO
                NovoVeiculoRequest listaveiculos = new NovoVeiculoRequest(
                        item.id(), item.getPlaca(), item.getMarca(), item.getModelo(), item.getCor());

                // monta o JSON com as infos
                String json = """
                        "Placa": %s,
                        "Marca": %s,
                        "modelo": %s,
                        "Cor": %s
                        """.formatted(
                        listaveiculos.placa(),
                        listaveiculos.marca(),
                        listaveiculos.modelo(),
                        listaveiculos.cor());

                // envia o JSON
                Json.Response_enviar(response, HttpServletResponse.SC_OK, json);
            }
        } catch (SQLException e) {
            Json.erro(response, HttpServletResponse.SC_NO_CONTENT, "Não ha conteudo no banco de dados");
            throw new RuntimeException(e);
        }
        return;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // TODO: DAOVeiculo.inserir(idCliente, placa, marca, modelo, cor)

        DAOVeiculo dao = new DAOVeiculo();

        try{
            String jsonMobile = request.getReader().lines().collect(Collectors.joining());
            JSONObject jsonObject = new JSONObject(jsonMobile);
            int cliente = jsonObject.getInt("idcliente");

            NovoVeiculoRequest novoVeiculo = new NovoVeiculoRequest(
                    cliente,
                    jsonObject.getString("placa"),
                    jsonObject.getString("marca"),
                    jsonObject.getString("modelo"),
                    jsonObject.getString("cor")
            );

            dao.inserir(
                    novoVeiculo.id(),
                    novoVeiculo.placa(),
                    novoVeiculo.marca(),
                    novoVeiculo.modelo(),
                    novoVeiculo.cor()
            );

            String json = """
                    "cliente": %d,
                    "placa": %s,
                    "marca": %s,
                    "modelo": %s,
                    "cor": %s
                    """.formatted(
                            novoVeiculo.id(),
                            novoVeiculo.placa(),
                            novoVeiculo.marca(),
                            novoVeiculo.modelo(),
                            novoVeiculo.cor()
            );
            Json.Response_enviar(response, HttpServletResponse.SC_OK, json);

        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // TODO: DAOVeiculo.remover(idCliente, id) com o id lido do pathInfo (/{id})
        response.sendError(HttpServletResponse.SC_NOT_IMPLEMENTED);
    }
}
