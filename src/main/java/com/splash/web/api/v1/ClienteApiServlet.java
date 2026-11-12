package com.splash.web.api.v1;

import java.io.IOException;
import java.sql.SQLException;

import com.splash.web.api.ApiServlet;
import com.splash.web.api.Json;
import com.splash.web.api.dto.AtualizarPerfilRequest;
import com.splash.web.api.dto.ClienteResumo;
import com.splash.web.db.DAOCliente;
import com.splash.web.model.Cliente;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * <pre>
 * GET   /api/v1/usuarios?idcliente=1 -> {id, nome, cpf, telefone, email}
 * PATCH /api/v1/usuarios {idcliente, nome?, telefone?, email?} -> {id, nome, cpf, telefone, email}
 * </pre>
 *
 * Erros: sempre {@code {"erro": "mensagem"}} (ver {@link Json#erro}).
 * TODO: o {@code idcliente} deve vir do token quando a autenticação for implementada.
 */
@WebServlet("/api/v1/usuarios")
public class ClienteApiServlet extends ApiServlet {

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
            Cliente cliente = new DAOCliente().getusuario(idCliente);
            Json.Response_ok(response, resumoJson(cliente).toString());

        } catch (IllegalArgumentException e) {
            // DAOCliente.getusuario: nenhum cliente com este id
            Json.erro(response, HttpServletResponse.SC_NOT_FOUND, e.getMessage());
        } catch (SQLException e) {
            getServletContext().log("Erro ao consultar cliente " + idCliente, e);
            Json.erro(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Houve um erro no acesso ao banco");
        }
    }

    @Override
    protected void doPatch(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        DAOCliente dao = new DAOCliente();

        int idCliente;
        AtualizarPerfilRequest perfil;
        try {
            JSONObject corpo = Json.lerCorpo(request);
            idCliente = corpo.getInt("idcliente");
            // "opt": nem toda atualização envia todos os campos (ausente → null → não altera)
            perfil = new AtualizarPerfilRequest(
                    corpo.optString("nome", null),
                    corpo.optString("telefone", null),
                    corpo.optString("email", null));
        } catch (JSONException e) {
            Json.erro(response, HttpServletResponse.SC_BAD_REQUEST, "Requisição inválida: " + e.getMessage());
            return;
        }

        try {
            Cliente cliente;
            try {
                cliente = dao.getusuario(idCliente);
            } catch (IllegalArgumentException e) {
                // nenhum cliente com este id
                Json.erro(response, HttpServletResponse.SC_NOT_FOUND, e.getMessage());
                return;
            }

            try {
                // Os setters validam/normalizam (Validacao) e lançam IllegalArgumentException
                if (perfil.nome() != null) cliente.setNome(perfil.nome());
                if (perfil.telefone() != null) cliente.setTelefone(perfil.telefone());
                if (perfil.email() != null) cliente.setEmail(perfil.email());

                dao.updateUsuarios(cliente.getId_cliente(), cliente.getNome(), cliente.getTelefone(),
                        cliente.getEmail());
            } catch (IllegalArgumentException e) {
                Json.erro(response, HttpServletResponse.SC_UNPROCESSABLE_CONTENT, e.getMessage());
                return;
            }

            Json.Response_ok(response, resumoJson(cliente).toString());

        } catch (SQLException e) {
            getServletContext().log("Erro ao atualizar cliente " + idCliente, e);
            Json.erro(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Houve um erro interno na atualização");
        }
    }

    /** {@code {id, nome, cpf, telefone, email}} do cliente (campos de texto entre aspas, JSON válido). */
    private static JSONObject resumoJson(Cliente cliente) {
        ClienteResumo resumo = new ClienteResumo(cliente.getId_cliente(), cliente.getNome(), cliente.getCpf(),
                cliente.getTelefone(), cliente.getEmail());
        return new JSONObject()
                .put("id", resumo.id())
                .put("nome", Json.ouNulo(resumo.nome()))
                .put("cpf", Json.ouNulo(resumo.cpf()))
                .put("telefone", Json.ouNulo(resumo.telefone()))
                .put("email", Json.ouNulo(resumo.email()));
    }
}
