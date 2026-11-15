package com.splash.web.api.v1;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;

import com.splash.web.api.ApiAuthFilter;
import com.splash.web.api.ApiServlet;
import com.splash.web.api.Json;
import com.splash.web.api.dto.NovoVeiculoRequest;
import com.splash.web.db.DAOVeiculo;
import com.splash.web.model.Validacao;
import com.splash.web.model.dto.VeiculoView;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * <pre>
 * GET    /api/v1/veiculos              -> [{id_veiculo, placa, marca, modelo, cor}]
 * POST   /api/v1/veiculos              {placa, marca, modelo, cor?} -> 201 {id_veiculo, placa, marca, modelo, cor}
 * PATCH  /api/v1/veiculos/{idVeiculo}  {placa?, marca?, modelo?, cor?} -> 200 {id_veiculo, placa, marca, modelo, cor}
 *         (campo ausente não muda; "cor" vazia ou null apaga a cor; 404 se não for do cliente; 409 placa repetida)
 * DELETE /api/v1/veiculos/{idVeiculo}  -> 200 {mensagem}
 * </pre>
 *
 * Erros: sempre {@code {"erro": "mensagem"}} (ver {@link Json#erro}).
 * Autenticação: o cliente é o da sessão (ver {@link ApiAuthFilter}); o app não envia {@code idcliente}.
 */
@WebServlet("/api/v1/veiculos/*")
public class VeiculoApiServlet extends ApiServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // O cliente vem da sessão (ApiAuthFilter), nunca da URL
        int idCliente = ApiAuthFilter.idAutenticado(request);

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
                    ApiAuthFilter.idAutenticado(request),
                    corpo.getString("placa"),
                    corpo.getString("marca"),
                    corpo.getString("modelo"),
                    corpo.optString("cor", null)); // cor é opcional

            int idVeiculo = new DAOVeiculo().inserir(
                    novoVeiculo.id(),
                    novoVeiculo.placa(),
                    novoVeiculo.marca(),
                    novoVeiculo.modelo(),
                    novoVeiculo.cor());

            JSONObject criado = new JSONObject();
            criado.put("id_veiculo", idVeiculo);
            criado.put("placa", Validacao.placa(novoVeiculo.placa())); // já validada pela DAO
            criado.put("marca", novoVeiculo.marca().trim());
            criado.put("modelo", novoVeiculo.modelo().trim());
            criado.put("cor", Json.ouNulo(novoVeiculo.cor() == null || novoVeiculo.cor().isBlank()
                    ? null : novoVeiculo.cor().trim()));
            Json.Response_enviar(response, HttpServletResponse.SC_CREATED, criado.toString());

        } catch (JSONException e) {
            // corpo vazio/inválido, campo ausente ou com tipo errado
            Json.erro(response, HttpServletResponse.SC_BAD_REQUEST, "Requisição inválida: " + e.getMessage());
        } catch (IllegalArgumentException e) {
            // regra da DAO (placa inválida, cliente inexistente ou inativo)
            Json.erro(response, HttpServletResponse.SC_UNPROCESSABLE_CONTENT, e.getMessage());
        } catch (SQLIntegrityConstraintViolationException e) {
            Json.erro(response, HttpServletResponse.SC_CONFLICT, "Placa já cadastrada");
        } catch (SQLException e) {
            getServletContext().log("Erro ao cadastrar veículo", e);
            Json.erro(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Houve um erro no acesso ao banco");
        }
    }

    @Override
    protected void doPatch(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int idCliente = ApiAuthFilter.idAutenticado(request);
        int idVeiculo;
        try {
            String rota = request.getPathInfo();
            if (rota == null || rota.length() < 2) {
                throw new NumberFormatException();
            }
            idVeiculo = Integer.parseInt(rota.substring(1));
        } catch (NumberFormatException e) {
            Json.erro(response, HttpServletResponse.SC_BAD_REQUEST,
                    "Informe o veículo no caminho: /api/v1/veiculos/{idVeiculo}");
            return;
        }

        JSONObject corpo;
        try {
            corpo = Json.lerCorpo(request);
        } catch (JSONException e) {
            Json.erro(response, HttpServletResponse.SC_BAD_REQUEST, "Requisição inválida: " + e.getMessage());
            return;
        }

        try {
            DAOVeiculo dao = new DAOVeiculo();
            VeiculoView atual = dao.listarPorCliente(idCliente).stream()
                    .filter(v -> v.getId() == idVeiculo).findFirst().orElse(null);
            if (atual == null) {
                Json.erro(response, HttpServletResponse.SC_NOT_FOUND, "Veículo não encontrado");
                return;
            }

            // Campo ausente (ou texto em branco) mantém o valor atual; só "cor" pode ser apagada
            String placa = Validacao.placa(corpo.optString("placa", atual.getPlaca()));
            String marca = textoOu(corpo, "marca", atual.getMarca());
            String modelo = textoOu(corpo, "modelo", atual.getModelo());
            String cor = corpo.has("cor") ? corpo.optString("cor", null) : atual.getCor();
            cor = cor == null || cor.isBlank() ? null : cor.trim();

            if (!dao.atualizar(idCliente, idVeiculo, placa, marca, modelo, cor)) {
                Json.erro(response, HttpServletResponse.SC_NOT_FOUND, "Veículo não encontrado");
                return;
            }

            Json.Response_ok(response, new JSONObject()
                    .put("id_veiculo", idVeiculo)
                    .put("placa", placa)
                    .put("marca", marca)
                    .put("modelo", modelo)
                    .put("cor", Json.ouNulo(cor)).toString());

        } catch (IllegalArgumentException e) {
            // placa inválida (Validacao.placa)
            Json.erro(response, HttpServletResponse.SC_UNPROCESSABLE_CONTENT, e.getMessage());
        } catch (SQLIntegrityConstraintViolationException e) {
            Json.erro(response, HttpServletResponse.SC_CONFLICT, "Placa já cadastrada");
        } catch (SQLException e) {
            getServletContext().log("Erro ao atualizar veículo " + idVeiculo, e);
            Json.erro(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Houve um erro no acesso ao banco");
        }
    }

    private static String textoOu(JSONObject corpo, String campo, String atual) {
        String valor = corpo.optString(campo, null);
        return valor == null || valor.isBlank() ? atual : valor.trim();
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // DELETE também não tem corpo confiável: o veículo vem no path (/{idVeiculo}); o cliente, da sessão
        int idCliente = ApiAuthFilter.idAutenticado(request);
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
