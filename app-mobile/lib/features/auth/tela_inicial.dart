import 'package:flutter/material.dart';

import 'package:flash_splash/core/constants/app_assets.dart';
import 'package:flash_splash/core/data/repositorio.dart';
import 'package:flash_splash/core/models/servico.dart';
import 'package:flash_splash/core/theme/app_theme.dart';
import 'package:flash_splash/features/auth/login_cliente.dart';

// Cores com transparência usadas só nesta tela.
const Color _vidro = Color(0x14FFFFFF); // branco ~8%
const Color _bordaVidro = Color(0x404FC7DB); // ciano ~25%

// Alturas usadas para dividir a tela entre ilustração e textos.
const double _alturaBarraTopo = 56;
const double _alturaTextos = 290;
const double _alturaMinimaImagem = 240;
const double _alturaMaximaImagem = 600;

/// Tela de abertura pensada para celular em pé: barra no topo, ilustração
/// grande no meio e, embaixo (onde o polegar alcança), título e botões.
class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final GlobalKey _chaveServicos = GlobalKey();

  void _abrirLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginCliente(),
      ),
    );
  }

  void _irParaServicos() {
    final contexto = _chaveServicos.currentContext;
    if (contexto == null) return;
    Scrollable.ensureVisible(
      contexto,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.gradienteFundo),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // A primeira "dobra" ocupa a tela toda; os serviços
                  // aparecem ao rolar ou ao tocar em "Ver serviços".
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: _Abertura(
                      alturaTela: constraints.maxHeight,
                      onAgendar: _abrirLogin,
                      onVerServicos: _irParaServicos,
                      onEntrar: _abrirLogin,
                    ),
                  ),
                  _SecaoServicos(
                    key: _chaveServicos,
                    onAgendar: _abrirLogin,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Abertura extends StatelessWidget {
  final double alturaTela;
  final VoidCallback onAgendar;
  final VoidCallback onVerServicos;
  final VoidCallback onEntrar;

  const _Abertura({
    required this.alturaTela,
    required this.onAgendar,
    required this.onVerServicos,
    required this.onEntrar,
  });

  @override
  Widget build(BuildContext context) {
    final margens = MediaQuery.of(context).padding;
    final alturaTopo = margens.top + _alturaBarraTopo;

    // A ilustração ocupa o que sobra entre a barra e os textos.
    final alturaImagem = (alturaTela - alturaTopo - _alturaTextos - margens.bottom)
        .clamp(_alturaMinimaImagem, _alturaMaximaImagem)
        .toDouble();

    // Cor do fundo (gradiente da tela) nas bordas da imagem, para o degradê
    // da ilustração se misturar sem emenda.
    final corNoTopo = Color.lerp(
      AppTheme.petroleoEscuro,
      AppTheme.petroleoMedio,
      (alturaTopo / alturaTela).clamp(0.0, 1.0),
    )!;
    final corNaBase = Color.lerp(
      AppTheme.petroleoEscuro,
      AppTheme.petroleoMedio,
      ((alturaTopo + alturaImagem) / alturaTela).clamp(0.0, 1.0),
    )!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra do topo: logo + Entrar
            Padding(
              padding: EdgeInsets.fromLTRB(24, margens.top, 24, 0),
              child: SizedBox(
                height: _alturaBarraTopo,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.local_car_wash,
                          color: AppTheme.ciano,
                          size: 28,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Fast Splash',
                          style: TextStyle(
                            color: AppTheme.superficie,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: onEntrar,
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.superficie,
                      ),
                      child: const Text(
                        'Entrar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Ilustração em largura total
            SizedBox(
              width: double.infinity,
              height: alturaImagem,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const _Ilustracao(),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [corNoTopo, corNoTopo.withAlpha(0)],
                        stops: const [0.0, 0.12],
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [corNaBase.withAlpha(0), corNaBase],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Título, texto e botões (parte de baixo da tela)
        Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, margens.bottom + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Lavagem rápida,\nagendada em\n'),
                    TextSpan(
                      text: 'segundos.',
                      style: TextStyle(color: AppTheme.ciano),
                    ),
                  ],
                ),
                style: TextStyle(
                  color: AppTheme.superficie,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Escolha o serviço, o dia e o horário. A gente cuida do '
                'resto e você acompanha cada etapa.',
                style: TextStyle(
                  color: AppTheme.bordaClara,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: onAgendar,
                        child: const Text('Agendar lavagem'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: onVerServicos,
                        child: const Text('Ver serviços'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Ilustração da abertura (retrato, 4:5). Em telas mais baixas ela é cortada
/// por cima e por baixo, mantendo o carro sempre visível. Se o arquivo
/// faltar, mostra um desenho simples no lugar.
class _Ilustracao extends StatelessWidget {
  const _Ilustracao();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Ilustração de um carro sendo lavado com espuma',
      image: true,
      child: Image.asset(
        AppAssets.hero,
        fit: BoxFit.cover,
        alignment: const Alignment(0, 0.65),
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              color: _vidro,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: _bordaVidro),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.local_car_wash,
              size: 96,
              color: AppTheme.ciano,
            ),
          );
        },
      ),
    );
  }
}

class _SecaoServicos extends StatelessWidget {
  final VoidCallback onAgendar;

  const _SecaoServicos({super.key, required this.onAgendar});

  @override
  Widget build(BuildContext context) {
    final margens = MediaQuery.of(context).padding;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, margens.top + 16, 24, margens.bottom + 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Escolha como mudar o nível',
            style: TextStyle(
              color: AppTheme.superficie,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Escolha o seu serviço e agende em poucos toques.',
            style: TextStyle(color: AppTheme.bordaClara, fontSize: 15),
          ),
          const SizedBox(height: 18),
          for (final servico in Repositorio.servicos)
            _CartaoServico(servico: servico, onTap: onAgendar),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onAgendar,
              child: const Text('Agendar lavagem'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartaoServico extends StatelessWidget {
  final Servico servico;
  final VoidCallback onTap;

  const _CartaoServico({required this.servico, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: _vidro,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _bordaVidro),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(servico.icone, color: AppTheme.ciano, size: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        servico.nome,
                        style: const TextStyle(
                          color: AppTheme.superficie,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        servico.descricao,
                        style: const TextStyle(color: AppTheme.bordaClara),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  servico.precoFormatado,
                  style: const TextStyle(
                    color: AppTheme.coral,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
