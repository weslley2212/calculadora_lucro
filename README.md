# Calculadora de Lucro 📊

Aplicativo Android para controle de compras, vendas e lucro de produtos.

## Funcionalidades
- ✅ Cadastro de produtos (nome, compra, venda)
- ✅ Cálculo automático de lucro
- ✅ Resumo financeiro total
- ✅ Editar e excluir produtos
- ✅ Busca por nome
- ✅ Filtros (maior lucro, menor lucro, mais recente, mais antigo)
- ✅ Gráfico de barras e pizza (FL Chart)
- ✅ Calendário mensal com gastos e lucros por mês
- ✅ Exportação de relatório PDF
- ✅ Modo claro e escuro
- ✅ Armazenamento local com Hive (offline)

## Como compilar no FlutLab

1. Acesse https://flutlab.io
2. Clique em "Upload as ZIP file"
3. Envie este arquivo ZIP
4. Aguarde o projeto carregar
5. Clique em "Get Packages"
6. Clique em "Build" → "Build APK"
7. Baixe e instale o APK no Android

## Estrutura do projeto

```
lib/
├── main.dart                    # Entrada do app
├── models/
│   ├── produto.dart             # Model de produto
│   └── produto.g.dart           # Adapter Hive
├── services/
│   ├── hive_service.dart        # CRUD local
│   └── pdf_service.dart         # Geração de PDF
├── viewmodels/
│   └── produto_viewmodel.dart   # Lógica e estado (Provider)
├── views/
│   ├── home_view.dart           # Tela principal
│   └── calendario_view.dart     # Calendário mensal
└── widgets/
    ├── resumo_card.dart         # Card de totais
    ├── produto_card.dart        # Card de produto
    ├── produto_form.dart        # Formulário + dialog edição
    └── graficos_widget.dart     # Gráficos FL Chart
```
