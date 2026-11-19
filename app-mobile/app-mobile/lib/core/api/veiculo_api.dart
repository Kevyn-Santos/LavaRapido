import 'dart:convert';

import 'package:flash_splash/core/api/api_client.dart';
import 'package:flash_splash/core/api/api_exception.dart';
import 'package:flash_splash/core/api/model/veiculo_model.dart';

/// Veículos do cliente logado. O servidor identifica o cliente pela sessão (cookie):
/// nenhuma chamada recebe ou envia o id do cliente.
class VeiculoApi {
  final APIClient apiClient;

  VeiculoApi({required this.apiClient});

  /// `GET /veiculos`.
  Future<List<VeiculoModel>> listar() => comTratamentoDeRede(() async {
        final resposta = await apiClient.get('/veiculos');
        if (resposta.statusCode != 200) throw ApiException.deResposta(resposta);
        final lista = jsonDecode(utf8.decode(resposta.bodyBytes)) as List<dynamic>;
        return [for (final item in lista) VeiculoModel.fromJson(item as Map<String, dynamic>)];
      });

  /// `POST /veiculos` (201) -> o [VeiculoModel] criado, já com o id (não precisa chamar [listar]).
  /// [cor] é opcional na API. Erros: 409 placa já cadastrada, 422 dado inválido.
  Future<VeiculoModel> cadastrar({
    required String placa,
    required String marca,
    required String modelo,
    String? cor,
  }) =>
      comTratamentoDeRede(() async {
        final resposta = await apiClient.post('/veiculos', body: {
          'placa': placa,
          'marca': marca,
          'modelo': modelo,
          if (cor != null && cor.trim().isNotEmpty) 'cor': cor.trim(),
        });
        if (resposta.statusCode != 201) throw ApiException.deResposta(resposta);
        return VeiculoModel.fromJson(jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>);
      });

  /// `PATCH /veiculos/{id}` (200). Só os campos informados mudam; [cor] vazia apaga a cor.
  /// Erros: 404 veículo de outro cliente, 409 placa repetida, 422 placa inválida.
  Future<VeiculoModel> atualizar(
    String idVeiculo, {
    String? placa,
    String? marca,
    String? modelo,
    String? cor,
  }) =>
      comTratamentoDeRede(() async {
        final resposta = await apiClient.patch('/veiculos/$idVeiculo', body: {
          if (placa != null) 'placa': placa,
          if (marca != null) 'marca': marca,
          if (modelo != null) 'modelo': modelo,
          if (cor != null) 'cor': cor,
        });
        if (resposta.statusCode != 200) throw ApiException.deResposta(resposta);
        return VeiculoModel.fromJson(jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>);
      });

  /// `DELETE /veiculos/{id}` (200). 404 se o veículo não for do cliente logado.
  Future<void> excluir(String idVeiculo) => comTratamentoDeRede(() async {
        final resposta = await apiClient.delete('/veiculos/$idVeiculo');
        if (resposta.statusCode != 200) throw ApiException.deResposta(resposta);
      });
}
