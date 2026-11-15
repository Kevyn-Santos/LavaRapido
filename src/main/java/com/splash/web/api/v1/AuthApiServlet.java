package com.splash.web.api.v1;

import java.io.IOException;
import java.sql.SQLException;

import com.splash.web.api.ApiAuthFilter;
import com.splash.web.api.Json;
import com.splash.web.db.DAOCliente;
import com.splash.web.model.Cliente;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * Rota pública de autenticação (sem passar pelo ApiAuthFilter). O app mobile só faz login;
 * o cadastro de clientes existe apenas na web ({@code /cadastro}).
 *
 * <pre>
 * POST /api/v1/auth/login {email, senha} -> {cliente}  (abre a sessão; o cookie JSESSIONID vem no Set-Cookie)
 * </pre>
 */
@WebServlet("/api/v1/auth/*")
public class AuthApiServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String rota = request.getPathInfo();
        if ("/login".equals(rota)) {
            login(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void login(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String email;
        String senha;
        try {
            JSONObject corpo = Json.lerCorpo(request);
            email = corpo.getString("email");
            senha = corpo.getString("senha");
        } catch (JSONException e) {
            Json.erro(response, HttpServletResponse.SC_BAD_REQUEST, "Requisição inválida: " + e.getMessage());
            return;
        }
        if (email.isBlank() || senha.isEmpty()) {
            Json.erro(response, HttpServletResponse.SC_BAD_REQUEST, "E-mail e senha são obrigatórios");
            return;
        }

        try {
            Cliente cliente = new DAOCliente().autenticarPorEmail(email, senha);
            if (cliente == null) {
                // Mensagem única: não revela se o e-mail existe
                Json.erro(response, HttpServletResponse.SC_UNAUTHORIZED, "E-mail ou senha inválidos");
                return;
            }

            // Login ok: abre a sessão (HttpSession) guardando o id; o Tomcat devolve o cookie JSESSIONID.
            // Mesmo padrão do LoginServlet do site web (descarta a sessão anterior).
            HttpSession anterior = request.getSession(false);
            if (anterior != null) {
                anterior.invalidate();
            }
            request.getSession(true).setAttribute(ApiAuthFilter.SESSAO_CLIENTE_ID, cliente.getId_cliente());

            JSONObject resposta = new JSONObject()
                    .put("cliente", new JSONObject()
                            .put("id", cliente.getId_cliente())
                            .put("nome", Json.ouNulo(cliente.getNome()))
                            .put("cpf", Json.ouNulo(cliente.getCpf()))
                            .put("telefone", Json.ouNulo(cliente.getTelefone()))
                            .put("email", Json.ouNulo(cliente.getEmail())));
            Json.Response_ok(response, resposta.toString());

        } catch (SQLException e) {
            getServletContext().log("Erro no login da API", e);
            Json.erro(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Houve um erro no acesso ao banco");
        }
    }
}
