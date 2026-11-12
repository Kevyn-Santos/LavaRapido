package com.splash.web.api.v1;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;

import com.splash.web.api.Json;
import com.splash.web.api.dto.NovoVeiculoRequest;
import com.splash.web.db.DAOVeiculo;
import com.splash.web.model.dto.VeiculoView;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * <pre>
 * GET    /api/v1/veiculos?idcliente=1       -> [{id_veiculo, placa, marca, modelo, cor}]
 * POST   /api/v1/veiculos                   {idcliente, placa, marca, modelo, cor} -> 201 {id_cliente, placa, marca, modelo, cor}
 * DELETE /api/v1/veiculos/{idVeiculo}?idcliente=1 -> 200 {mensagem}
 * </pre>
 *
 * Erros: sempre {@code {"erro": "mensagem"}} (ver {@link Json#erro}).
 * TODO: o {@code idcliente} deve vir do token quando a autenticação for implementada.
 */
@WebServlet("/api/v1/veiculos/*")
public class VeiculoApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // GET não tem corpo confiável: o cliente vem na query string (?idcliente=1)
        int idCliente;
        try {
            idCliente = Json.parametroInt(request, "idcliente");
        } catch (IllegalArgumentException e) {
            Json.erro(response, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
            return;
        }

        try {
            JSONArray lista = new JSONArray();

            for (VeiculoView item : new DAOVeiculo().listarPorCliente(idCliente)) {
                JSONObject veiculo = new JSONObject();
                veiculo.put("id_veiculo", item.getId());
                veiculo.put("placa", item.getPlaca());
                veiculo.put("marca", item.getMarca());
                veiculo.put("modelo", item.getModelo());
                veiculo.put("cor", Json.ouNulo(item.getCor()));
                lista.put(veiculo);
            }

            // Uma única resposta com o array inteiro ([] quando o cliente não tem veículos)
            Json.Response_ok(response, lista.toString());

        } catch (SQLException e) {
            getServletContext().log("Erro ao listar veículos do cliente " + idCliente, e);
            Json.erro(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Houve um erro no acesso ao banco");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            JSONObject corpo = Json.lerCorpo(request);

            // NovoVeiculoRequest.id carrega o id do cliente dono do veículo
            NovoVeiculoRequest novoVeiculo = new NovoVeiculoRequest(
                    corpo.getInt("idcliente"),
                    corpo.getString("placa"),
                    corpo.getString("marca"),
                    corpo.getString("modelo"),
                    corpo.getString("cor"));

            new DAOVeiculo().inserir(
                    novoVeiculo.id(),
                    novoVeiculo.placa(),
                    novoVeiculo.marca(),
                    novoVeiculo.modelo(),
                    novoVeiculo.cor());

            JSONObject criado = new JSONObject();
            criado.put("id_cliente", novoVeiculo.id());
            criado.put("placa", novoVeiculo.placa());
            criado.put("marca", novoVeiculo.marca());
            criado.put("modelo", novoVeiculo.modelo());
            criado.put("cor", novoVeiculo.cor());
            Json.Response_enviar(response, HttpServletResponse.SC_CREATED, criado.toString());

        } catch (JSONException e) {
            // corpo vazio/inválido, campo ausente ou com tipo errado
            Json.erro(response, HttpServletResponse.SC_BAD_REQUEST, "Requisição inválida: " + e.getMessage());
        } catch (IllegalArgumentException e) {
            // regra da DAO (cliente inexistente ou inativo)
            Json.erro(response, HttpServletResponse.SC_UNPROCESSABLE_CONTENT, e.getMessage());
        } catch (SQLIntegrityConstraintViolationException e) {
            Json.erro(response, HttpServletResponse.SC_CONFLICT, "Placa já cadastrada");
        } catch (SQLException e) {
            getServletContext().log("Erro ao cadastrar veículo", e);
            Json.erro(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Houve um erro no acesso ao banco");
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // DELETE também não tem corpo confiável: o veículo vem no path (/{idVeiculo}) e o cliente na query
        int idCliente;
        int idVeiculo;
        try {
            String rota = request.getPathInfo(); // "/3" ou null
            if (rota == null || rota.length() < 2) {
                throw new IllegalArgumentException("Informe o veículo no caminho: /api/v1/veiculos/{idVeiculo}");
            }
            try {
                idVeiculo = Integer.parseInt(rota.substring(1));
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException("Identificador de veículo inválido");
            }
            idCliente = Json.parametroInt(request, "idcliente");
        } catch (IllegalArgumentException e) {
            Json.erro(response, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
            return;
        }

        try {
            if (new DAOVeiculo().remover(idCliente, idVeiculo)) {
                Json.Response_ok(response, new JSONObject()
                        .put("mensagem", "Veículo %d excluído com sucesso".formatted(idVeiculo)).toString());
            } else {
                Json.erro(response, HttpServletResponse.SC_NOT_FOUND, "Veículo ou cliente não encontrado na base");
            }
        } catch (IllegalArgumentException e) {
            // ids <= 0 rejeitados pela DAO
            Json.erro(response, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (SQLException e) {
            getServletContext().log("Erro ao excluir veículo " + idVeiculo, e);
            Json.erro(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Houve um erro no acesso ao banco");
        }
    }
}
