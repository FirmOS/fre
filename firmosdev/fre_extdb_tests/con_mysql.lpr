program con_mysql;

{$mode objfpc}{$H+}

uses sqldb, fre_mysql_ll;

Var
  C : TSQLConnection;
  T : TSQLTransaction;
  Q : TSQLQuery;

var i : integer;
begin
  C:=TFOSMySqlConn.Create(Nil);
  try
    C.UserName:='root';
    C.Password:='kmuRZ2013$';
    c.HostName:='crm';
    C.DatabaseName:='crm_citycom';
    T:=TSQLTransaction.Create(C);
    T.Database:=C;
    C.Connected:=True;
    Q:=TSQLQuery.Create(C);
    Q.Database:=C;
    Q.Transaction:=T;
    q.sql.Text := 'SET CHARACTER SET `utf8`';
    q.ExecSQL;
    q.sql.Text := 'SET NAMES `utf8`';
    q.ExecSQL;
    //Q.SQL.Text:='SELECT *.accounts FROM accounts';
    Q.SQL.Text:='SELECT accounts.*,accounts_cstm.* FROM `accounts_cstm` RIGHT OUTER JOIN `accounts` ON (`accounts_cstm`.`id_c` = `accounts`.`id`)';
    Q.Open;
    While not Q.EOF do
      begin
        WriteLn(q.FieldByName('id').AsString,' ',q.FieldByName('name').AsString);
        Q.Next
      end;
    Q.Close;
  finally
    C.Free;
  end;
end.
