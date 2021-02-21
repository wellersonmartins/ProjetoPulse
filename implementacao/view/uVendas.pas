unit uVendas;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  VirtualTrees, uProdutoController, uVendasController, uPesquisaProduto;

type
  TFVenda = class(TForm)
    Panel1: TPanel;
    Panel3: TPanel;
    Panel2: TPanel;
    btnIncluir: TButton;
    txtQuantidade: TEdit;
    Label1: TLabel;
    txtProduto: TLabel;
    txtcodProduto: TEdit;
    txtValorUnitario: TEdit;
    Label2: TLabel;
    txtValorTot: TEdit;
    Label3: TLabel;
    Panel4: TPanel;
    cGrid: TVirtualStringTree;
    Panel5: TPanel;
    lblSubTotal: TLabel;
    btnFinalizar: TButton;
    btnCancelar: TButton;
    btnExluir: TButton;
    btnPesquisaProduto: TButton;
    lbl1: TLabel;
    procedure btnIncluirClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnPesquisaProdutoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure txtcodProdutoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cGridGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure txtQuantidadeChange(Sender: TObject);
    procedure btnFinalizarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnExluirClick(Sender: TObject);
  private
    function valorTotal: Currency;
  public
    ProdutoCtr: TProdutoController;
    CtrVendas: TVendasController;
    procedure Inserir(sErro: string);
    procedure FinalizaVenda(sErro: String);
    procedure VerificaPedidoAberto;

    procedure limpaCampos;
    procedure CarregaGridVendas(codigo: Integer);
  end;

var
  FVenda: TFVenda;

var
  codigoPro, NewPed: Integer;

implementation

{$R *.dfm}

procedure TFVenda.btnCancelarClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TFVenda.btnExluirClick(Sender: TObject);
var Node: PVirtualNode;
sErro: string;
begin
   Node := cGrid.GetFirstSelected;
   if Assigned(Node) then
   begin
     CtrVendas.Vendas := CtrVendas.VendasList[Node.Index];
     if CtrVendas.Remover(sErro) then
     begin
       CarregaGridVendas(0);
       limpaCampos;

     end
     else
      ShowMessage(sErro);
   end;
end;

procedure TFVenda.btnFinalizarClick(Sender: TObject);
begin
  FinalizaVenda('');
end;

procedure TFVenda.btnIncluirClick(Sender: TObject);
begin
  Inserir('');
end;

procedure TFVenda.btnPesquisaProdutoClick(Sender: TObject);
var
  P: TFPesquisaProduto;
begin
  P := TFPesquisaProduto.Create(nil);
  try
    p.PesquisaPadrao := txtcodProduto.Text;
    p.ShowModal;

    if P.ModalResult = mrOk then
    begin
      ProdutoCtr.Produto.ID := p.ProdutoCtr.Produto.ID;
      codigoPro := p.ProdutoCtr.Produto.ID;
      ProdutoCtr.Produto.Descricao := p.ProdutoCtr.Produto.Descricao;
      ProdutoCtr.Produto.valor := p.ProdutoCtr.Produto.valor;

      txtcodProduto.Text := FormatFloat('000000', ProdutoCtr.Produto.ID) + '-' + ProdutoCtr.Produto.Descricao;
      txtValorUnitario.Text := FormatFloat(',0.00', ProdutoCtr.Produto.valor);
      txtQuantidade.SetFocus;
    end;
  finally
    P.Destroy;
  end;
end;

procedure TFVenda.CarregaGridVendas(codigo: Integer);
begin
    if codigo = 0 then
     CtrVendas.CarregaPedido(0,True,Date, Date)
    else
      CtrVendas.CarregaPedido(codigo,False,0,0 );

    cGrid.Clear;
    cGrid.RootNodeCount := CtrVendas.VendasList.Count;
end;

procedure TFVenda.cGridGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
begin
  case Column of
    00:
      CellText := FormatFloat('000000', CtrVendas.VendasList[Node.Index].car_codProduto) + '-' + CtrVendas.VendasList[Node.Index].car_descriPro;
    01:
      CellText := FormatFloat('000', CtrVendas.VendasList[Node.Index].car_quantidade);
    02:
      CellText := FormatFloat(',0.00', CtrVendas.VendasList[Node.Index].car_valorUnitario);
    03:
      CellText := FormatFloat(',0.00', CtrVendas.VendasList[Node.Index].car_valorTotal);
  end;

end;

procedure TFVenda.FinalizaVenda(sErro: String);
begin

  if CtrVendas.FinalizaVendaCtr(sErro) then
  begin
    limpaCampos;
    cGrid.Clear;
    lblSubTotal.Caption := '';
    ShowMessage('Pedido finalizado com sucesso!')
  end
  else
    ShowMessage(sErro);
end;

procedure TFVenda.FormCreate(Sender: TObject);
begin
  ProdutoCtr := TprodutoController.Create;
  CtrVendas := TVendasController.Create;
end;

procedure TFVenda.FormDestroy(Sender: TObject);
begin
  ProdutoCtr.Destroy;
  CtrVendas.Destroy;
end;

procedure TFVenda.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_RETURN:
      btnIncluir.SetFocus;
  end;
end;

procedure TFVenda.FormShow(Sender: TObject);
begin
//  VerificaPedidoAberto;
end;

procedure TFVenda.Inserir(sErro: string);
begin
  CtrVendas.Vendas.car_codigo     := CtrVendas.NewCod;
  CtrVendas.Vendas.car_codProduto := codigoPro;
  CtrVendas.Vendas.car_quantidade := StrToInt(txtQuantidade.Text);
  CtrVendas.Vendas.car_valorUnitario := StrToCurr(txtValorUnitario.Text);
  CtrVendas.Vendas.car_valorTotal := StrToCurr(txtValorTot.Text);
  CtrVendas.Vendas.car_finalizado := False;
  if CtrVendas.Inserir(sErro) then
  begin
    limpaCampos;
    CarregaGridVendas(CtrVendas.Vendas.car_codigo);
    lblSubTotal.Caption := 'R$ ' + FloatToStr(CtrVendas.SomaTotalVendas);
  end
  else
    ShowMessage(sErro);
end;

procedure TFVenda.limpaCampos;
var componett: TComponentClass;
 i: Integer;
begin
 for I := 0 to Self.ComponentCount -1 do
  begin
    if (Self.Components[i] is TEdit) and (not ((Self.Components[i] as TEdit).Name = 'txtQuantidade' )) then
      (Self.Components[i] as TEdit).text :=  '';
 end;
end;

procedure TFVenda.txtcodProdutoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if key = VK_RETURN then
    btnPesquisaProduto.Click;
end;

procedure TFVenda.txtQuantidadeChange(Sender: TObject);
begin
  txtValorTot.Text := CurrToStr(valorTotal);
end;

function TFVenda.valorTotal: Currency;
begin
  if (txtQuantidade.Text = '0') or (txtQuantidade.Text = '') then
    txtQuantidade.Text := '1';
  Result := StrToCurr(txtValorUnitario.Text) * StrToInt(txtQuantidade.Text);
end;

procedure TFVenda.VerificaPedidoAberto;
begin
  if CtrVendas.VerificaPedido then
  begin
   if MessageDlg('Existe pedidos n�o finalizados! Deseja carrega-lo?',
     mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
   begin
      CarregaGridVendas(1);
      lblSubTotal.Caption := 'R$ ' + CurrToStr(CtrVendas.SomaTotalVendas);
   end
   else
   begin
     CtrVendas.VendasList.Clear;
   end;
  end;
end;

end.

