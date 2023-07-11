﻿program SampleTest1;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils, IxUnitTest;

var
  exparr: array of Byte;
  actarr: array of Byte;

begin
  try

    SetLength(exparr, 8);
    SetLength(actarr, 8);

    for var i := 0 to High(exparr) do
    begin
      exparr[i] := i;
      actarr[i] := i;
    end;

{$IF true}
    System.Writeln('■■■ Test Start ■■■ 全テスト成功');
    TestSuit.Open;
    assertEquals('Test1-1', 1, 1);
    assertEquals('Test1-2', 16000000, 16000000);
    assertEquals('Test1-3', 1.1, 1.2, 0.1);
    assertEquals('Test1-4', 1.11, 1.12, 0.011);
    assertEquals('Test1-5', 'abc', 'abc');
    assertEquals('Test1-6', true, true);
    assertEquals('Test1-7', exparr, actarr);
    TestSuit.Close;
    System.Writeln(TestSuit.Log.Text);
{$ENDIF}
{$IF true}
    System.Writeln('■■■ Test2 Start ■■■ 全テスト失敗');
    TestSuit.Open;
    assertEquals('Test2-1-1', 1, 2);
    assertEquals('Test2-1-2', 1, -1);
    assertEquals('Test2-1-3', 4, 16000000);
    assertEquals('Test2-2-1', 1.1, 1.2);
    assertEquals('Test2-2-2', 1.1, 1.2, 0.09);
    assertEquals('Test2-2-3', 1.11, 1.12, 0.01);
    assertEquals('Test2-3-1', 'xbc', 'abc');
    assertEquals('Test2-3-2', 'axc', 'abc');
    assertEquals('Test2-3-3', 'abx', 'abc');
    assertEquals('Test2-3-4', 'abc', 'xbc');
    assertEquals('Test2-3-5', 'abc', 'axc');
    assertEquals('Test2-3-6', 'abc', 'abx');
    assertEquals('Test2-3-7', 'abc', 'abcd');
    assertEquals('Test2-3-8', 'abcd', 'abc');
    assertEquals('Test2-3-9', '', 'abc');
    assertEquals('Test2-3-10', 'abc', '');
    assertEquals('Test2-4-1', true, false);
    SetLength(actarr, 9);
    assertEquals('Test2-5-1', exparr, actarr);
    SetLength(actarr, 8);
    actarr[3] := 8;
    assertEquals('Test2-5-1', exparr, actarr);
    TestSuit.Close;
    System.Writeln(TestSuit.Log.Text);
{$ENDIF}
{$IF true}
    System.Writeln('■■■ Test Start ■■■ 1個失敗');
    TestSuit.Open;
    assertEquals('Test3-1', 1, 1, true);
    assertEquals('Test3-2', 16000000, 16000001, true);
    assertEquals('Test3-3', 1.1, 1.1);
    assertEquals('Test3-4', 'abc', 'abc');
    TestSuit.Close;
    System.Writeln(TestSuit.Log.Text);
{$ENDIF}
{$IF true}
    System.Writeln('■■■ Test4 Start ■■■ テスト無し');
    TestSuit.Open;
    TestSuit.Close;
    System.Writeln(TestSuit.Log.Text);
{$ENDIF}
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
