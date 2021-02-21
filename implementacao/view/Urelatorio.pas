unit Urelatorio;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, frxClass, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  frxDBSet, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,uVendasController, ufuncoes,
  Datasnap.DBClient, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask;

type
  TForm_rel = class(TForm)
    frxRelVendas: TfrxReport;
    frxDados: TfrxDBDataset;
    cdDados: TClientDataSet;
    cdDadosCodigo: TIntegerField;
    cdDadosDescricao: TStringField;
    cdDadosUnidade: TIntegerField;
    cdDadosvlrunit: TStringField;
    cdDadosvlrtot: TStringField;
    dsDados: TDataSource;
    Panel1: TPanel;
    Button1: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    edData1: TMaskEdit;
    edData2: TMaskEdit;
    Sair: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure SairClick(Sender: TObject);
  private
    { Private declarations }
  public
   CtrVendas: TVendasController;

  end;

var
  Form_rel: TForm_rel;

implementation

{$R *.dfm}

procedure TForm_rel.Button1Click(Sender: TObject);
var i: integer;
begin
  CtrVendas.CarregaPedido(0,True,StrToDate(edData1.Text), StrToDate(edData2.Text));
 cdDados.CreateDataSet;
 cdDados.Open;
 for I := 0 to CtrVendas.VendasList.Count -1 do
 begin
    cdDados.Append;
    cdDadosCodigo.Value:= CtrVendas.VendasList[i].car_codProduto;
    cdDadosDescricao.Value:= CtrVendas.VendasList[i].car_descriPro;
    cdDadosUnidade.Value:= CtrVendas.VendasList[i].car_quantidade;
    cdDadosvlrunit.Value:= FormatFloat('#,##0.00',CtrVendas.VendasList[i].car_valorUnitario);
    cdDadosvlrtot.Value:= FormatFloat('#,##0.00',CtrVendas.VendasList[i].car_valorTotal);
    cdDados.Post;
 end;
 frxRelVendas.ShowReport();
 FreeAndNil(CtrVendas);
end;

procedure TForm_rel.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Self.Close;
end;

procedure TForm_rel.FormCreate(Sender: TObject);
begin
 CtrVendas := TVendasController.Create;
end;

procedure TForm_rel.SairClick(Sender: TObject);
begin
  Close;
end;

end.
