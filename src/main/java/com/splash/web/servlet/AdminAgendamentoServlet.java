
package com.splash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.splash.web.db.DAOAgendamento;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/agendamentos")
public class AdminAgendamentoServlet extends HttpServlet {

    /** Atributos de sessão lidos (e removidos) por {@code PainelServlet}. */
    static final String ERRO_FLASH = "erroAgendamento";
    static final String RASCUNHO_FLASH = "rascunhoAgendamento";

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

            if ("cancelar".equals(acao)) {

                Integer idAgendamento = WebSupport.inteiro(
                        WebSupport.campo(request, "idAgendamento"));

                if (idAgendamento == null || idAgendamento <= 0) {
                    throw new IllegalArgumentException(
                            "Agendamento inválido.");
                }

                boolean cancelado = new DAOAgendamento()
                        .cancelarAdministrativo(idAgendamento);

                if (!cancelado) {
                    throw new IllegalArgumentException(
                            "Agendamento não encontrado, já cancelado, concluído ou com pagamento realizado.");
                }

                response.sendRedirect(
                        request.getContextPath()
                                + "/painel/agendamentos?sucesso=1");
                return;
            }

            if (!"agendar".equals(acao)) {
                throw new IllegalArgumentException(
                        "Ação de agendamento inválida.");
            }

            Integer idCliente = WebSupport.inteiro(
                    WebSupport.campo(request, "idCliente"));

            Integer idVeiculo = WebSupport.inteiro(
                    WebSupport.campo(request, "idVeiculo"));

            if (idCliente == null || idCliente <= 0
                    || idVeiculo == null || idVeiculo <= 0) {
                throw new IllegalArgumentException(
                        "Selecione um cliente e um veículo válidos.");
            }

            LocalDate data = LocalDate.parse(
                    WebSupport.campo(request, "data"));

            LocalTime horario = LocalTime.parse(
                    WebSupport.campo(request, "horario"));

            if (data.isBefore(LocalDate.now())) {
                throw new IllegalArgumentException(
                        "Não é possível agendar uma data anterior à atual.");
            }

            String[] idsRecebidos = request.getParameterValues("idServicos");

            if (idsRecebidos == null || idsRecebidos.length == 0) {
                throw new IllegalArgumentException(
                        "Selecione pelo menos um serviço.");
            }

            List<Integer> idsServicos = new ArrayList<>();

            for (String valor : idsRecebidos) {

                Integer idServico = WebSupport.inteiro(valor);

                if (idServico == null || idServico <= 0) {
                    throw new IllegalArgumentException(
                            "Um dos serviços selecionados é inválido.");
                }

                idsServicos.add(idServico);
            }

            DAOAgendamento dao = new DAOAgendamento();

            dao.criar(
                    idCliente,
                    idVeiculo,
                    data,
                    horario.toString(),
                    idsServicos);

            response.sendRedirect(
                    request.getContextPath()
                            + "/painel/agendamentos?sucesso=1");

        } catch (DateTimeParseException exception) {
            // A mensagem do Java é em inglês: o usuário recebe texto fixo em português
            voltarComErro(request, response, "Informe uma data e um horário válidos.");
        } catch (IllegalArgumentException exception) {
            voltarComErro(request, response, exception.getMessage());
        } catch (SQLException exception) {

            if (exception.getSQLState() != null
                    && exception.getSQLState().startsWith("23")) {

                voltarComErro(request, response,
                    "Conflito ao cadastrar o agendamento. "
                    + "Verifique a disponibilidade do veículo e horário.");
                return;
            }

            WebSupport.erroBanco(request, response, exception);
        }
    }

    /**
     * Guarda a mensagem e o que foi digitado na sessão (flash) e volta para a tela de agendamentos,
     * que mostra o erro no próprio formulário e preenche os campos de novo. Evita a página de erro
     * do servidor. {@code PainelServlet} lê e remove os atributos.
     */
    private void voltarComErro(HttpServletRequest request, HttpServletResponse response, String mensagem)
            throws IOException {
        Map<String, Object> rascunho = new HashMap<>();
        for (String campo : new String[] { "idCliente", "idVeiculo", "data", "horario" }) {
            rascunho.put(campo, WebSupport.campo(request, campo));
        }
        String[] servicos = request.getParameterValues("idServicos");
        rascunho.put("idServicos", servicos == null ? List.of() : List.of(servicos));

        HttpSession session = request.getSession();
        session.setAttribute(ERRO_FLASH, mensagem);
        session.setAttribute(RASCUNHO_FLASH, rascunho);
        response.sendRedirect(request.getContextPath() + "/painel/agendamentos");
    }
}
