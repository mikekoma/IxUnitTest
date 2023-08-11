program SampleTest1;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.Classes, System.SysUtils, IxUnitTest;

var
  exparr: array of Byte;
  actarr: array of Byte;
  expstringlist: TStringList;
  actstringlist: TStringList;

begin
  try
    SetLength(exparr, 8);
    SetLength(actarr, 8);

    for var i := 0 to High(exparr) do
    begin
      exparr[i] := i;
      actarr[i] := i;
    end;

    expstringlist := TStringList.Create;
    actstringlist := TStringList.Create;

    expstringlist.Add('abc');
    expstringlist.Add('def');
    actstringlist.Assign(expstringlist);

{$IF true}
    System.Writeln('■■■ Test Start ■■■ 全(8)テスト成功');
    TestSuit.Open;
    assertEquals('Test1-1', 1, 1);
    assertEquals('Test1-2', 16000000, 16000000);
    assertEquals('Test1-3', 1.1, 1.2, 0.1);
    assertEquals('Test1-4', 1.11, 1.12, 0.011);
    assertEquals('Test1-5', 'abc', 'abc');
    assertEquals('Test1-6', true, true);
    assertEquals('Test1-7', exparr, actarr);
    assertEquals('Test1-8', expstringlist, actstringlist);
    TestSuit.Close;
    System.Writeln(TestSuit.Log.Text);
{$ENDIF}
{$IF true}
    System.Writeln('■■■ Test2 Start ■■■ 全(22)テスト失敗');
    TestSuit.Open;
    assertEquals('Test2-1', 1, 2);
    assertEquals('Test2-2', 1, -1);
    assertEquals('Test2-3', 4, 16000000);
    assertEquals('Test2-4', 1.1, 1.2, 0.01);
    assertEquals('Test2-5', 1.1, 1.2, 0.09);
    assertEquals('Test2-6', 1.11, 1.12, 0.01);
    assertEquals('Test2-7', 'xbc', 'abc');
    assertEquals('Test2-8', 'axc', 'abc');
    assertEquals('Test2-9', 'abx', 'abc');
    assertEquals('Test2-10', 'abc', 'xbc');
    assertEquals('Test2-11', 'abc', 'axc');
    assertEquals('Test2-12', 'abc', 'abx');
    assertEquals('Test2-13', 'abc', 'abcd');
    assertEquals('Test2-14', 'abcd', 'abc');
    assertEquals('Test2-15', '', 'abc');
    assertEquals('Test2-16', 'abc', '');
    assertEquals('Test2-17', true, false);

    SetLength(actarr, 9);
    assertEquals('Test2-18', exparr, actarr);

    SetLength(actarr, 8);
    actarr[3] := 8;
    assertEquals('Test2-19', exparr, actarr);

    actstringlist.Add('ghi');
    assertEquals('Test2-20', expstringlist, actstringlist);

    actstringlist.Delete(2);
    expstringlist.Add('ghi');
    assertEquals('Test2-21', expstringlist, actstringlist);

    expstringlist.Delete(2);
    actstringlist.Strings[1] := 'dxf';
    assertEquals('Test2-22', expstringlist, actstringlist);

    TestSuit.Close;
    System.Writeln(TestSuit.Log.Text);
{$ENDIF}
{$IF true}
    System.Writeln('■■■ Test Start ■■■ HEX 1個失敗');
    TestSuit.Open;
    assertEquals('Test3-1', 1, 1, utHEX);
    assertEquals('Test3-2', 16000000, 16000001, utHEX);
    assertEquals('Test3-3', 1.1, 1.1, 0.1);
    assertEquals('Test3-4', 'abc', 'abc');
    TestSuit.Close;
    System.Writeln(TestSuit.Log.Text);
{$ENDIF}
{$IF true}
    System.Writeln('■■■ Test Start ■■■ BIN 1個失敗');
    TestSuit.Open;
    assertEquals('Test4-1', 1, 1, utHEX);
    assertEquals('Test4-2', $12345678, $12355678, utBIN);
    assertEquals('Test4-3', 1.1, 1.1, 0.1);
    assertEquals('Test4-4', 'abc', 'abc');
    TestSuit.Close;
    System.Writeln(TestSuit.Log.Text);
{$ENDIF}
{$IF true}
    System.Writeln('■■■ Test5 Start ■■■ テスト無しはエラーになる');
    TestSuit.Open;
    TestSuit.Close;
    System.Writeln(TestSuit.Log.Text);
{$ENDIF}
{$IF true}
    System.Writeln('■■■ Test99 Start ■■■ 成功で終わる');
    TestSuit.Open;
    assertEquals('Test99', 1, 1);
    TestSuit.Close;
    System.Writeln(TestSuit.Log.Text);
{$ENDIF}
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
