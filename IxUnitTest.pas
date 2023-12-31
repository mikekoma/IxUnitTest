﻿{
  IxUnitTest

  ■2023-10-13 Ver1.06
  Uint8の比較追加
  整数の比較結果出力、10進数と16進数が逆だったのを修正

  ■2023-08-11 Ver1.05
  バイナリ比較を追加

  ■2023-08-06 Ver1.04
  UInt64追加
  TDateTime追加

  ■2023-07-12 Ver1.03
  TStrings追加

  ■2023-07-11 Ver1.02
  クラス名変更 TIxMinUnit -> TIxUnitTest
  Console削除
  array of byte用追加

  ■2017-11-24 Ver1.01
  クラス名変更 IxMinUnit -> TIxMinUnit
  クラス名変更 IxMunUnitModule -> TIxMinUnitModule
  assertEqualsにmsg追加
  singleをdoubleに変更

  ■2011-06-06 Ver1.00
}
{
  ■使い方
  usesにIxUnitTest追加

  テストを記述して実行
  TestSuit.Closeを実行して結果を集計

  Logに結果が入るので、それを表示する。
  IsOkで成功失敗をboolean取得可能
}

unit IxUnitTest;

interface

uses Classes, SysUtils, StrUtils, System.Generics.Collections;

// 定義DEFINEは、未定義はUNDEF
{$UNDEF IXUNITTEST_ENABLE_ASSERT} // 定義すると例外発生
{$DEFINE IXUNITTEST_MSG_JP} // 定義するとメッセージが日本語になる

const
  STR_TAB = '    ';
{$IFDEF IXUNITTEST_MSG_JP}
  STR_EXP = STR_TAB + '期待';
  STR_DIF = STR_TAB + '差異';
  STR_ACT = STR_TAB + '実際';
  STR_DLT = STR_TAB + '許容';
  STR_ERR = STR_TAB + '誤差';
  STR_LEN_EXP = STR_TAB + 'Length(期待[]) = ';
  STR_LEN_ACT = STR_TAB + 'Length(実際[]) = ';
  STR_ARR_EXP = STR_TAB + '期待[] = ';
  STR_ARR_DIF = STR_TAB + '差異     ';
  STR_ARR_ACT = STR_TAB + '実際[] = ';
  STR_OK = 'OK.';
  STR_NG = 'NG!!Σ（￣□￣|||）';
{$ELSE}
  STR_EXP = STR_TAB + 'EXP';
  STR_DIF = STR_TAB + 'DIF';
  STR_ACT = STR_TAB + 'ACT';
  STR_DLT = STR_TAB + 'DELTA';
  STR_ERR = STR_TAB + 'ERR';
  STR_LEN_EXP = STR_TAB + 'Length(exp[]) = ';
  STR_LEN_ACT = STR_TAB + 'Length(act[]) = ';
  STR_ARR_EXP = STR_TAB + 'exp[] = ';
  STR_ARR_DIF = STR_TAB + 'diff    ';
  STR_ARR_ACT = STR_TAB + 'act[] = ';
  STR_OK = 'OK.';
  STR_NG = 'NG!! (-_-)';
{$ENDIF}

type
  TIxUnitType = (utDEC, utHEX, utBIN);

type
  TIxUnitTest = class(TObject)
  private
  protected
  public
    SuccessCount: integer; // テスト成功回数
    ErrorCount: integer; // テスト失敗回数

    Log: TStrings;
    LogQueue: TThreadedQueue<string>; // オブジェクトを割り当てると、ログ出力追加

    constructor Create;
    destructor Destroy; override;

    procedure LogMsg(msg: string);
    procedure Open;
    procedure Close;

    function IsOk: boolean;
  end;

  {
    exp 期待値
    act 実際の値
  }
function assertEquals(msg: string; exp, act: boolean): boolean; overload;
function assertEquals(msg: string; exp, act: string): boolean; overload;
function assertEquals(msg: string; exp, act: Double; err_range: Double = 0): boolean; overload;
function assertEquals(msg: string; exp, act: UInt8; utype: TIxUnitType = utDEC): boolean; overload; // Word
function assertEquals(msg: string; exp, act: UInt16; utype: TIxUnitType = utDEC): boolean; overload; // Word
function assertEquals(msg: string; exp, act: UInt32; utype: TIxUnitType = utDEC): boolean; overload; // Longword
function assertEquals(msg: string; exp, act: Int32; utype: TIxUnitType = utDEC): boolean; overload; // integer(32bit)
function assertEquals(msg: string; exp, act: UInt64; utype: TIxUnitType = utDEC): boolean; overload; // unsigned integer(64it)
function assertEquals(msg: string; exp, act: TDateTime): boolean; overload;
function assertEquals(msg: string; exp, act: array of Byte): boolean; overload;
function assertEquals(msg: string; exp, act: TStrings): boolean; overload;

type
  TIxUnitTestModule = class(TObject)
  public
    procedure Run; virtual; abstract;
  end;

var
  TestSuit: TIxUnitTest;

implementation

function int_to_bin(val: UInt64; num: integer): string;
var
  str: string;
  bit: UInt64;
begin
  bit := 1;
  for var i := 0 to num - 1 do
  begin
    if (val and bit) <> 0 then
      str := '1' + str
    else
      str := '0' + str;

    if ((i + 1) mod 4) = 0 then
      str := '_' + str;

    bit := bit shl 1;
  end;

  Result := str;
end;

function int_to_bindiff(exp, act: UInt64; num: integer): string;
var
  str: string;
  bit: UInt64;
begin
  bit := 1;
  for var i := 0 to num - 1 do
  begin
    if ((exp and bit) xor (act and bit)) <> 0 then
      str := '|' + str
    else
      str := ' ' + str;

    if ((i + 1) mod 4) = 0 then
      str := ' ' + str;

    bit := bit shl 1;
  end;

  Result := str;
end;

{ IxUnitTest }

procedure TIxUnitTest.Open;
begin
  SuccessCount := 0;
  ErrorCount := 0;
  Log.Clear;
end;

constructor TIxUnitTest.Create;
begin
  Log := TStringList.Create;
  LogQueue := nil;
  Open;
end;

destructor TIxUnitTest.Destroy;
begin
  Log.Free;

  inherited;
end;

procedure TIxUnitTest.LogMsg(msg: string);
begin
  Log.Add(msg);

  if LogQueue <> nil then
    LogQueue.PushItem(msg);
end;

procedure TIxUnitTest.Close;
begin
  LogMsg('');
  LogMsg('Success = ' + IntToStr(SuccessCount));
  LogMsg('Error = ' + IntToStr(ErrorCount));
  LogMsg('');

  if IsOk then
    LogMsg(STR_OK)
  else
    LogMsg(STR_NG);
end;

function TIxUnitTest.IsOk: boolean;
begin
  if ErrorCount > 0 then
    Result := false // テスト失敗
  else if SuccessCount > 0 then
    Result := True // テスト成功
  else
    Result := false; // テスト未実行。未実行は失敗とする。
end;

function assertEquals(msg: string; exp, act: boolean): boolean;
begin
  if exp = act then
  begin
    inc(TestSuit.SuccessCount);
    Result := True;
  end
  else
  begin
    inc(TestSuit.ErrorCount);
    if msg <> '' then
      TestSuit.LogMsg(msg);

    TestSuit.LogMsg(STR_EXP + '(boolean) = ' + BoolToStr(exp));
    TestSuit.LogMsg(STR_ACT + '(boolean) = ' + BoolToStr(act));
{$IFDEF IXUNITTEST_ENABLE_ASSERT}
    Assert(false);
{$ENDIF}
    Result := false;
  end;
end;

function assertEquals(msg: string; exp, act: string): boolean;
begin
  if CompareStr(exp, act) = 0 then
  begin
    inc(TestSuit.SuccessCount);
    Result := True;
  end
  else
  begin
    inc(TestSuit.ErrorCount);
    if msg <> '' then
      TestSuit.LogMsg(msg);

    TestSuit.LogMsg(STR_EXP + '(string) = ' + exp);
    TestSuit.LogMsg(STR_ACT + '(string) = ' + act);
{$IFDEF IXUNITTEST_ENABLE_ASSERT}
    Assert(false);
{$ENDIF}
    Result := false;
  end;
end;

{
  演算誤差により、誤差範囲(err_range)と実際の誤差が一見一致しても、テスト失敗する事があるので注意
  is_ok := abs(exp - act) <= err_range
}
function assertEquals(msg: string; exp, act: Double; err_range: Double = 0): boolean;
var
  calc_err: Double;
begin
  calc_err := abs(exp - act);
  if calc_err <= err_range then
  begin
    inc(TestSuit.SuccessCount);
    Result := True;
  end
  else
  begin
    inc(TestSuit.ErrorCount);
    if msg <> '' then
      TestSuit.LogMsg(msg);

    TestSuit.LogMsg(STR_EXP + '(Double) = ' + FloatToStr(exp));
    TestSuit.LogMsg(STR_ACT + '(Double) = ' + FloatToStr(act));
    TestSuit.LogMsg(STR_DLT + '(Double) = ' + FloatToStr(err_range));
    TestSuit.LogMsg(STR_ERR + '(Double) = ' + FloatToStr(calc_err));
{$IFDEF IXUNITTEST_ENABLE_ASSERT}
    Assert(false);
{$ENDIF}
    Result := false;
  end;
end;

function assertEquals(msg: string; exp, act: UInt8; utype: TIxUnitType = utDEC): boolean;
var
  strexp: string;
  stract: string;
  strdif: string;
begin
  if exp = act then
  begin
    inc(TestSuit.SuccessCount);
    Result := True;
  end
  else
  begin
    inc(TestSuit.ErrorCount);
    if msg <> '' then
      TestSuit.LogMsg(msg);

    strdif := '';
    case utype of
      utDEC:
        begin
          strexp := IntToStr(exp);
          stract := IntToStr(act);
        end;
      utHEX:
        begin
          strexp := '$' + IntToHex(exp, sizeof(exp) * 2);
          stract := '$' + IntToHex(act, sizeof(exp) * 2);
        end;
      utBIN:
        begin
          strexp := '0b' + int_to_bin(exp, sizeof(exp) * 8);
          strdif := '0b' + int_to_bindiff(exp, act, sizeof(exp) * 8);
          stract := '0b' + int_to_bin(act, sizeof(exp) * 8);
        end;
    end;

    TestSuit.LogMsg(STR_EXP + '(UInt8) = ' + strexp);
    if strdif <> '' then
      TestSuit.LogMsg(STR_DIF + '(UInt8) = ' + strdif);
    TestSuit.LogMsg(STR_ACT + '(UInt8) = ' + stract);
{$IFDEF IXUNITTEST_ENABLE_ASSERT}
    Assert(false);
{$ENDIF}
    Result := false;
  end;
end;

function assertEquals(msg: string; exp, act: UInt16; utype: TIxUnitType = utDEC): boolean;
var
  strexp: string;
  stract: string;
  strdif: string;
begin
  if exp = act then
  begin
    inc(TestSuit.SuccessCount);
    Result := True;
  end
  else
  begin
    inc(TestSuit.ErrorCount);
    if msg <> '' then
      TestSuit.LogMsg(msg);

    strdif := '';
    case utype of
      utDEC:
        begin
          strexp := IntToStr(exp);
          stract := IntToStr(act);
        end;
      utHEX:
        begin
          strexp := '$' + IntToHex(exp, sizeof(exp) * 2);
          stract := '$' + IntToHex(act, sizeof(exp) * 2);
        end;
      utBIN:
        begin
          strexp := '0b' + int_to_bin(exp, sizeof(exp) * 8);
          strdif := '0b' + int_to_bindiff(exp, act, sizeof(exp) * 8);
          stract := '0b' + int_to_bin(act, sizeof(exp) * 8);
        end;
    end;

    TestSuit.LogMsg(STR_EXP + '(UInt16) = ' + strexp);
    if strdif <> '' then
      TestSuit.LogMsg(STR_DIF + '(UInt16) = ' + strdif);
    TestSuit.LogMsg(STR_ACT + '(UInt16) = ' + stract);
{$IFDEF IXUNITTEST_ENABLE_ASSERT}
    Assert(false);
{$ENDIF}
    Result := false;
  end;
end;

function assertEquals(msg: string; exp, act: UInt32; utype: TIxUnitType = utDEC): boolean;
var
  strexp: string;
  stract: string;
  strdif: string;
begin
  if exp = act then
  begin
    inc(TestSuit.SuccessCount);
    Result := True;
  end
  else
  begin
    inc(TestSuit.ErrorCount);
    if msg <> '' then
      TestSuit.LogMsg(msg);

    strdif := '';
    case utype of
      utDEC:
        begin
          strexp := IntToStr(exp);
          stract := IntToStr(act);
        end;
      utHEX:
        begin
          strexp := '$' + IntToHex(exp, sizeof(exp) * 2);
          stract := '$' + IntToHex(act, sizeof(exp) * 2);
        end;
      utBIN:
        begin
          strexp := '0b' + int_to_bin(exp, sizeof(exp) * 8);
          strdif := '0b' + int_to_bindiff(exp, act, sizeof(exp) * 8);
          stract := '0b' + int_to_bin(act, sizeof(exp) * 8);
        end;
    end;

    TestSuit.LogMsg(STR_EXP + '(UInt32) = ' + strexp);
    if strdif <> '' then
      TestSuit.LogMsg(STR_DIF + '(UInt32) = ' + strdif);
    TestSuit.LogMsg(STR_ACT + '(UInt32) = ' + stract);
{$IFDEF IXUNITTEST_ENABLE_ASSERT}
    Assert(false);
{$ENDIF}
    Result := false;
  end;
end;

function assertEquals(msg: string; exp, act: Int32; utype: TIxUnitType = utDEC): boolean;
var
  strexp: string;
  stract: string;
  strdif: string;
begin
  if exp = act then
  begin
    inc(TestSuit.SuccessCount);
    Result := True;
  end
  else
  begin
    inc(TestSuit.ErrorCount);
    if msg <> '' then
      TestSuit.LogMsg(msg);

    strdif := '';
    case utype of
      utDEC:
        begin
          strexp := IntToStr(exp);
          stract := IntToStr(act);
        end;
      utHEX:
        begin
          strexp := '$' + IntToHex(exp, sizeof(exp) * 2);
          stract := '$' + IntToHex(act, sizeof(exp) * 2);
        end;
      utBIN:
        begin
          strexp := '0b' + int_to_bin(exp, sizeof(exp) * 8);
          strdif := '0b' + int_to_bindiff(exp, act, sizeof(exp) * 8);
          stract := '0b' + int_to_bin(act, sizeof(exp) * 8);
        end;
    end;

    TestSuit.LogMsg(STR_EXP + '(Int32) = ' + strexp);
    if strdif <> '' then
      TestSuit.LogMsg(STR_DIF + '(Int32) = ' + strdif);
    TestSuit.LogMsg(STR_ACT + '(Int32) = ' + stract);
{$IFDEF IXUNITTEST_ENABLE_ASSERT}
    Assert(false);
{$ENDIF}
    Result := false;
  end;
end;

function assertEquals(msg: string; exp, act: UInt64; utype: TIxUnitType = utDEC): boolean;
var
  strexp: string;
  stract: string;
  strdif: string;
begin
  if exp = act then
  begin
    inc(TestSuit.SuccessCount);
    Result := True;
  end
  else
  begin
    inc(TestSuit.ErrorCount);
    if msg <> '' then
      TestSuit.LogMsg(msg);

    strdif := '';
    case utype of
      utDEC:
        begin
          strexp := IntToStr(exp);
          stract := IntToStr(act);
        end;
      utHEX:
        begin
          strexp := '$' + IntToHex(exp, sizeof(exp) * 2);
          stract := '$' + IntToHex(act, sizeof(exp) * 2);
        end;
      utBIN:
        begin
          strexp := '0b' + int_to_bin(exp, sizeof(exp) * 8);
          strdif := '0b' + int_to_bindiff(exp, act, sizeof(exp) * 8);
          stract := '0b' + int_to_bin(act, sizeof(exp) * 8);
        end;
    end;

    TestSuit.LogMsg(STR_EXP + '(UInt64) = ' + strexp);
    if strdif <> '' then
      TestSuit.LogMsg(STR_DIF + '(UInt64) = ' + strdif);
    TestSuit.LogMsg(STR_ACT + '(UInt64) = ' + stract);
{$IFDEF IXUNITTEST_ENABLE_ASSERT}
    Assert(false);
{$ENDIF}
    Result := false;
  end;
end;

{
  バイト配列の比較
  テスト失敗時、最大64バイトまでは比較結果を表示する
}
function assertEquals(msg: string; exp, act: array of Byte): boolean;
var
  len_exp, len_act: integer;
  err_count: integer;
  exp_str, act_str, dif_str: string;
  len_limit: boolean;
begin
  len_exp := Length(exp);
  len_act := Length(act);
  if len_exp <> len_act then
  begin
    // 長さが違う
    inc(TestSuit.ErrorCount);
    if msg <> '' then
      TestSuit.LogMsg(msg);

    TestSuit.LogMsg(STR_LEN_EXP + IntToStr(len_exp));
    TestSuit.LogMsg(STR_LEN_ACT + IntToStr(len_act));
    Result := false;
    Exit;
  end;

  err_count := 0;
  for var i := 0 to len_exp - 1 do
  begin
    if exp[i] <> act[i] then
    begin
      inc(err_count);
      break;
    end;
  end;

  if err_count = 0 then
  begin
    // 成功
    inc(TestSuit.SuccessCount);
    Result := True;
    Exit;
  end;

  // ここから相違あり(テスト失敗)
  inc(TestSuit.ErrorCount);
  if msg <> '' then
    TestSuit.LogMsg(msg);

  len_limit := false;
  if len_exp > 64 then
  begin
    len_exp := 64;
    len_limit := True;
  end;

  exp_str := '';
  act_str := '';
  dif_str := '';
  for var i := 0 to len_exp - 1 do
  begin
    exp_str := exp_str + IntToHex(exp[i], 2) + ' ';
    act_str := act_str + IntToHex(act[i], 2) + ' ';
    if exp[i] <> act[i] then
      dif_str := dif_str + '|| '
    else
      dif_str := dif_str + '   ';
  end;

  if len_limit then
  begin
    exp_str := exp_str + '...';
    act_str := act_str + '...';
    dif_str := dif_str + '...';
  end;

  TestSuit.LogMsg(STR_ARR_EXP + exp_str);
  TestSuit.LogMsg(STR_ARR_DIF + dif_str);
  TestSuit.LogMsg(STR_ARR_ACT + act_str);

  Result := false;
end;

function assertEquals(msg: string; exp, act: TDateTime): boolean;
var
  strexp: string;
  stract: string;
begin
  if exp = act then
  begin
    inc(TestSuit.SuccessCount);
    Result := True;
  end
  else
  begin
    inc(TestSuit.ErrorCount);
    if msg <> '' then
      TestSuit.LogMsg(msg);

    DateTimeToString(strexp, 'yyyy-mm-dd hh:nn:ss zzz', exp);
    DateTimeToString(stract, 'yyyy-mm-dd hh:nn:ss zzz', act);

    TestSuit.LogMsg(STR_EXP + '(TDateTime) = ' + strexp);
    TestSuit.LogMsg(STR_ACT + '(TDateTime) = ' + stract);
{$IFDEF IXUNITTEST_ENABLE_ASSERT}
    Assert(false);
{$ENDIF}
    Result := false;
  end;
end;

function assertEquals(msg: string; exp, act: TStrings): boolean;
begin
  if exp.Count <> act.Count then
  begin
    inc(TestSuit.ErrorCount);
    if msg <> '' then
      TestSuit.LogMsg(msg);

    TestSuit.LogMsg(STR_EXP + '(TStrings.Count) = ' + IntToStr(exp.Count));
    TestSuit.LogMsg(STR_ACT + '(TStrings.Count) = ' + IntToStr(act.Count));

    Result := false;
    Exit;
  end;

  for var i := 0 to exp.Count - 1 do
  begin
    if exp[i] <> act[i] then
    begin
      inc(TestSuit.ErrorCount);
      if msg <> '' then
        TestSuit.LogMsg(msg);

      TestSuit.LogMsg(STR_EXP + '(TStrings[' + i.ToString + ']) = ' + exp[i]);
      TestSuit.LogMsg(STR_ACT + '(TStrings[' + i.ToString + ']) = ' + act[i]);

      Result := false;
      Exit;
    end;
  end;

  Result := True;
end;

initialization

TestSuit := TIxUnitTest.Create;

finalization

TestSuit.Free;

end.
