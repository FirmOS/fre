program normalize_test;

uses sysutils;

function NormalizeTNNumber(text: string;NormalizeGreater:integer;InternationalAreaCode,InterNationalPrefixReplace,NationalArea,DialPrefix,NationalPrefix:string;const internatexpand:boolean=false): string;
var i,ln,lt,lac:integer;
    areacode:string;
    ac_vkz,ac_exists:boolean;
    int_dial,int_replaced,ac_replaced:boolean;
    s,tempic,tempic2,text_right,text_left:string;
    add_dialprefix:boolean;
    obrc,cbrc:integer;
    brbroken:boolean;
    brcode:string;

    function SeparateLeft(const Value, Delimiter: string): string;
    var
      x: Integer;
    begin
      x := Pos(Delimiter, Value);
      if x < 1 then
        Result := Value
      else
        Result := Copy(Value, 1, x - 1);
    end;

    {==============================================================================}

    function SeparateRight(const Value, Delimiter: string): string;
    var
      x: Integer;
    begin
      x := Pos(Delimiter, Value);
      if x > 0 then
        x := x + Length(Delimiter) - 1;
      Result := Copy(Value, x + 1, Length(Value) - x);
    end;

    function TrimSPLeft(const S: string): string;
    var
      I, L: Integer;
    begin
      L := Length(S);
      I := 1;
      while (I <= L) and (S[I] = ' ') do
        Inc(I);
      Result := Copy(S, I, Maxint);
    end;

begin
 result:='';
 if text<>'' then begin
  if text[1]='!' then begin
   result:=copy(text,2,maxint);
   exit;
  end;
 end else begin
  result:='';
  exit;
 end;

 ac_vkz:=false;
 ac_exists:=false;
 ac_replaced:=false;
 int_dial:=false;
 int_replaced:=false;
 add_dialprefix:=false;
 obrc:=0;cbrc:=0;

 for i:=1 to length(text) do begin // Strip Of every invalid Char
  if text[i] in ['0'..'9','(',')','+'] then begin
   s:=s+text[i];
   if text[i]='(' then begin
    inc(obrc);
   end;
   if text[i]=')' then begin
    inc(cbrc);
   end;
  end;
 end;

 text:=s;
 if text=''  then begin
  result:='';
  exit;
 end;

 brbroken:=false;
 if (obrc<>cbrc) or (cbrc>1) or (obrc>1) then begin // Bracket Rule broken
  brBroken:=true;
 end else begin
  if (obrc=1) and (cbrc=1) then begin
   brcode:=SeparateRight(text,'(');
   brcode:=SeparateLeft(brcode,')');
   if Pos('+',brcode)=1 then begin
    brbroken:=true;
   end;
   if Pos(InterNationalPrefixReplace,brcode)=1 then begin
    brbroken:=true;
   end;
  end;
 end;

 if brbroken then begin
  s:='';
  for i:=1 to length(text) do begin // Strip Of every invalid Char
   if text[i] in ['0'..'9','+'] then begin
    s:=s+text[i];
   end;
  end;
  text:=s;
 end;

 ln:=length(text);
 if pos('+',InternationalAreaCode)<>1 then begin
  InternationalAreaCode:='+'+InternationalAreaCode;
 end;
 tempic:=StringReplace(InternationalAreaCode,'+',InterNationalPrefixReplace,[]);
 if ln>=NormalizeGreater then begin
  if pos('+',text)<>0 then begin
   int_dial:=true;
  end;
  if InternationalAreaCode<>'' then begin
   if Pos(InternationalAreaCode,text)=1 then begin
    text:=StringReplace(text,InternationalAreaCode,'',[]);
    int_replaced:=true;
    int_dial:=true;
   end else begin
     if Pos(tempic,text)=1 then begin
      text:=StringReplace(text,tempic,'',[]);
      int_replaced:=true;
      int_dial:=true;
     end;
   end;
  end;
  areacode:='';
  if (Pos('(',text)>0) and (Pos(')',text)>0) then begin
   areacode:=SeparateRight(text,'(');
   areacode:=SeparateLeft(areacode,')');
   text_left:=SeparateLeft(text,'(');
   text_right:=SeparateRight(text,')');
   if areacode<>'' then begin
    ac_exists:=true;
   end;
   tempic2:=StringReplace(text_left,'+',InterNationalPrefixReplace,[]);
   if (pos('0',tempic2)=0) and (pos('+',tempic2)=0) and (tempic2<>'') then begin // 00 or + forgotten
    tempic2:=InterNationalPrefixReplace+tempic2;
    text_left:='+'+text_left;
   end;
   if (areacode<>'0') and (areacode<>'') then begin // Fix Stacktrace
    if areacode[1]='0' then begin
     areacode:=copy(areacode,2,maxint);
    end;
//    areacode:=StringReplace(areacode,'0','',[]);
   end else begin
    ac_exists:=false;
    areacode:='';
    text:=text_left+text_right;
    int_dial:=true;
   end;
  end;

//  if pos('+',text)=0 then begin // ONLY process Areacode when not International.
   if ac_exists then begin // Area Code in Brackets
    if NationalArea=areacode then begin
     if (tempic2=tempic) or (tempic2='') then begin // Same International Area
      text:=text_right;
      ac_replaced:=true;
      int_replaced:=true;
     end else begin
      text:=text_left+areacode+text_right;
      int_dial:=true;
     end;
    end else begin
     if (tempic2=tempic) or (tempic2='') then begin
      text:=areacode+text_right;
      ac_vkz:=true;
      int_replaced:=true;
     end else begin
      text:=text_left+areacode+text_right;
      int_dial:=true;
     end;
    end;
   end else begin
    lt:=Length(text);
    lac:=length(NationalArea);
    if (pos(NationalArea,text)=1)and (lt>=(lac+NormalizeGreater)) then begin // Area Code without Brackets
     text:=copy(text,length(NationalArea)+1,maxint);
     ac_replaced:=true;
//     int_replaced:=true;
    end;
    if (pos(NationalPrefix+NationalArea,text)=1)and (lt>=(lac+NormalizeGreater)) and (NationalArea<>'') then begin // Area Code without Brackets
     text:=copy(text,length(NationalPrefix+NationalArea)+1,maxint);
     ac_replaced:=true;
     int_replaced:=true;
    end;

   end;
//  end;
  text:=StringReplace(text,'+',InterNationalPrefixReplace,[]);
 // Always add Dial Prefix
  if DialPrefix<>'' then begin
//   if (ln=NormalizeGreater) and (text[1]='0') then begin // OK
   if (ln=NormalizeGreater) and (pos(DialPrefix,text)=1) then begin
    //Dial Prefix 0 already added by user Normylize 5 / 01503
   end else begin
    add_dialprefix:=true;
   end;
  end;
  if ac_vkz then begin
   result:=NationalPrefix+result;
  end else
  if int_dial and int_replaced and (not ac_replaced) then begin
   result:=NationalPrefix+result;
  end;
 end;
 if internatexpand=true then begin
    if pos(InterNationalPrefixReplace,text)=1 then begin
     int_dial:=true;
    end;
    add_dialprefix:=false;
    result:=DialPrefix;
    if ac_replaced then begin
     text:=NationalArea+text;
    end;
    if int_replaced then begin
     text:=tempic+text;
    end;
    if (int_dial=false) and not(ac_replaced or int_replaced) then begin
     if pos(NationalPrefix,text)=1 then begin // National AreaCode Strip
      text:=Copy(text,1+Length(NationalPrefix),maxint);
     end else begin // no national AC add default
      text:=NationalArea+text;
     end;
     text:=tempic+text;
    end;
 end;
 if add_dialprefix then begin
  result:=DialPrefix+result;
 end;
 for i:=1 to length(text) do begin // Strip Of every not number in between
  if text[i] in ['0'..'9'] then begin
   result:=result+text[i];
  end;
 end;
end;


procedure TestSuite;
var NormalizeGreater:integer;InternationalAreaCode,InterNationalPrefixReplace,NationalArea,DialPrefix,NationalPrefix:string;

 procedure Test(number,expected,iexpected:string;remark:string='');
 var s,ss,sss:string;

 begin
  ss:=NormalizeTNNumber(number,NormalizeGreater,InternationalAreaCode,InterNationalPrefixReplace,NationalArea,DialPrefix,NationalPrefix);
  sss:=NormalizeTNNumber(number,NormalizeGreater,InternationalAreaCode,InterNationalPrefixReplace,NationalArea,DialPrefix,NationalPrefix,true);
  if (expected=ss) and (iexpected=sss) then begin
   s:=number+' -> '+ss+' OK    Int:('+sss+') ';
  end else begin
   if expected<>ss then begin
    s:='!!'+number+' -> '+ss+' FAIL: EXPECTED '+expected;
    ss:=NormalizeTNNumber(number,NormalizeGreater,InternationalAreaCode,InterNationalPrefixReplace,NationalArea,DialPrefix,NationalPrefix);
   end else begin
    s:='!!'+number+' -> '+ss+' OK '+expected+'    INT FAILED:('+sss+') + EXPECTED ('+iexpected+')';
    ss:=NormalizeTNNumber(number,NormalizeGreater,InternationalAreaCode,InterNationalPrefixReplace,NationalArea,DialPrefix,NationalPrefix,true);
   end;
  end;
  if remark<>'' then begin
   s:=s+' '+remark;
  end;
  writeln(s);
 end;

 procedure ShowPrefixes;
 begin
  writeln('Normalisierung ab: '+inttostr(NormalizeGreater));
  writeln('Internationale Vorwahl: '+InternationalAreaCode);
  writeln('Nationale Vorwahl: '+NationalArea);
  writeln('+ Ersetzen durch: '+InterNationalPrefixReplace);
  writeln('Nationaler Prefix: '+NationalPrefix);
  writeln('Wahl Prefix: '+DialPrefix);
 end;
begin
  writeln;
  NormalizeGreater:=5;
  InternationalAreaCode:='+43';
  InterNationalPrefixReplace:='00';
  NationalArea:='316';
  NationalPrefix:='0';
  DialPrefix:='0';

  ShowPrefixes;

  Test('1','1','000433161');
  Test('11','11','0004331611');
  Test('111','111','00043316111');
  Test('1111','1111','000433161111');
  Test('11111','011111','0004331611111');
  Test('111111','0111111','00043316111111');

  Test('251119','0251119','00043316251119');
  Test('0316251119','0251119','00043316251119');
  Test('0317251119','00317251119','00043317251119');

  Test('06803009599','006803009599','000436803009599');
  Test('43316251119','043316251119','0004331643316251119');
  Test('43317251119','043317251119','0004331643317251119');
  Test('430316251119','0430316251119','00043316430316251119');

  Test('+43316251119','0251119','00043316251119');
  Test('0043316251119','0251119','00043316251119');
  Test('+43(316)251119','0251119','00043316251119');
  Test('0043(316)251119','0251119','00043316251119');
  Test('+43(0316)251119','0251119','00043316251119');
  Test('0043(0316)251119','0251119','00043316251119');
  Test('0 0 4 3 ( 3 1 6 ) 2 5 1 1 1  9 ','0251119','00043316251119');
  Test('+43 (0) 316251119','0251119','00043316251119');

  Test('+43-316-251119','0251119','00043316251119');
//  Test('43-(0)-316-2/5/1/1/1/9','0251119');
  Test('+43-317-2/5/1/1/1/9','00317251119','00043317251119');

  Test('43(316)251119','0251119','00043316251119');
  Test('43(0316)251119','0251119','00043316251119');

  Test('+43317251119','00317251119','00043317251119');
  Test('0043317251119','00317251119','00043317251119');
  Test('43(0317)251119','00317251119','00043317251119');
  Test('43(317)251119','00317251119','00043317251119');

  Test('+43-317-251119','00317251119','00043317251119');


  Test('49316251119','049316251119','0004331649316251119');
  Test('49(316)251119','00049316251119','00049316251119');
  Test('49(0316)251119','00049316251119','00049316251119');
  Test('+49(316)251119','00049316251119','00049316251119');
  Test('+49(0316)251119','00049316251119','00049316251119');
  Test('0049(316)251119','00049316251119','00049316251119');
  Test('0049(0316)251119','00049316251119','00049316251119');

  Test('49(0)316251119','00049316251119','00049316251119');
  Test('+49(0)316251119','00049316251119','00049316251119');
  Test('0049(0)316251119','00049316251119','00049316251119');


  Test('49(317)251119','00049317251119','00049317251119');
  Test('49(0317)251119','00049317251119','00049317251119');
  Test('+49(317)251119','00049317251119','00049317251119');
  Test('+49(0317)251119','00049317251119','00049317251119');

  Test('+43(0664)628-3197','006646283197','000436646283197');
  Test('+43(0650)628-3197','006506283197','000436506283197');

  Test('+43(0)650628-3197','006506283197','000436506283197');
  Test('0650628-3197','006506283197','000436506283197');
  Test('!**NONORM**$$1123','**NONORM**$$1123','**NONORM**$$1123');
  Test('+43 (660) 12345','0066012345','0004366012345');

  DialPrefix:='9';
  writeln('');
  writeln('Wahl Prefix: '+DialPrefix);
  writeln('');


  Test('1','1','900433161');
  Test('11','11','9004331611');
  Test('111','111','90043316111');
  Test('1111','1111','900433161111');
  Test('11111','911111','9004331611111');
  Test('111111','9111111','90043316111111');

  Test('251119','9251119','90043316251119');
  Test('0316251119','9251119','90043316251119');
  Test('0317251119','90317251119','90043317251119');

  Test('06803009599','906803009599','900436803009599');
  Test('43316251119','943316251119','9004331643316251119');
  Test('43317251119','943317251119','9004331643317251119');
  Test('430316251119','9430316251119','90043316430316251119');

  Test('+43316251119','9251119','90043316251119');
  Test('0043316251119','9251119','90043316251119');
  Test('+43(316)251119','9251119','90043316251119');
  Test('0043(316)251119','9251119','90043316251119');
  Test('+43(0316)251119','9251119','90043316251119');
  Test('0043(0316)251119','9251119','90043316251119');
  Test('0 0 4 3 ( 3 1 6 ) 2 5 1 1 1  9 ','9251119','90043316251119');
  Test('+43 (0) 316251119','9251119','90043316251119');

  Test('+43-316-251119','9251119','90043316251119');

  Test('+43-317-2/5/1/1/1/9','90317251119','90043317251119');

  Test('43(316)251119','9251119','90043316251119');
  Test('43(0316)251119','9251119','90043316251119');

  Test('+43317251119','90317251119','90043317251119');
  Test('0043317251119','90317251119','90043317251119');
  Test('43(0317)251119','90317251119','90043317251119');
  Test('43(317)251119','90317251119','90043317251119');

  Test('+43-317-251119','90317251119','90043317251119');


  Test('49316251119','949316251119','9004331649316251119');
  Test('49(316)251119','90049316251119','90049316251119');
  Test('49(0316)251119','90049316251119','90049316251119');
  Test('+49(316)251119','90049316251119','90049316251119');
  Test('+49(0316)251119','90049316251119','90049316251119');
  Test('0049(316)251119','90049316251119','90049316251119');
  Test('0049(0316)251119','90049316251119','90049316251119');

  Test('49(0)316251119','90049316251119','90049316251119');
  Test('+49(0)316251119','90049316251119','90049316251119');
  Test('0049(0)316251119','90049316251119','90049316251119');


  Test('49(317)251119','90049317251119','90049317251119');
  Test('49(0317)251119','90049317251119','90049317251119');
  Test('+49(317)251119','90049317251119','90049317251119');
  Test('+49(0317)251119','90049317251119','90049317251119');

  Test('+43(0664)628-3197','906646283197','900436646283197');
  Test('+43(0650)628-3197','906506283197','900436506283197');

  Test('+43(0)650628-3197','906506283197','900436506283197');
  Test('0650628-3197','906506283197','900436506283197');


  Test('+43 (660) 12345','9066012345','9004366012345');
  Test('(+43)6649876543','906649876543','900436649876543');
  Test('(+43664)9876543','906649876543','900436649876543');

  DialPrefix:='9';

  Test('(0043)6649876543','906649876543','900436649876543');
  Test('(0043664)9876543','906649876543','900436649876543');

  Test('(0049)6649876543','900496649876543','900496649876543');
  Test('(0049664)9876543','900496649876543','900496649876543');

  Test('(+49)6649876543','900496649876543','900496649876543');
  Test('(+49664)9876543','900496649876543','900496649876543');

  Test('((6649876543','96649876543','900433166649876543');
  Test('((664))9876543','96649876543','900433166649876543');
  Test('((664)9876543','96649876543','900433166649876543');
  Test('0043((664)987654)3','906649876543','900436649876543');
  Test('0043(0)(664)9876543','9006649876543','9004306649876543','Because of the bracket rule, (0) is handled as part of the number and an additional 0 is added');



  NormalizeGreater:=5;
  InternationalAreaCode:='+43';
  DialPrefix:='';
  InterNationalPrefixReplace:='00';
  NationalArea:='';

  ShowPrefixes;

  Test('06646283197','06646283197','00436646283197');
  Test('0316251119','0316251119','0043316251119');
  Test('(0316)251119','0316251119','0043316251119');
  Test('(0317)251119','0317251119','0043317251119');
  Test('0043316251119','0316251119','0043316251119');
  Test('0043317251119','0317251119','0043317251119');

  NormalizeGreater:=5;                              //Lettland
  InternationalAreaCode:='+371';
  DialPrefix:='0';
  InterNationalPrefixReplace:='00';
  NationalArea:='';
  NationalPrefix:='';

  ShowPrefixes;

  Test('+37129398545','029398545','00037129398545');
  Test('6646283197','06646283197','0003716646283197');
  Test('(316)251119','0316251119','000371316251119');
  Test('00371316251119','0316251119','000371316251119');

  NormalizeGreater:=5;
  InternationalAreaCode:='+371';
  DialPrefix:='';
  InterNationalPrefixReplace:='00';
  NationalArea:='';
  NationalPrefix:='';

  ShowPrefixes;

  Test('+37129398545','29398545','0037129398545');
  Test('6646283197','6646283197','003716646283197');
  Test('(316)251119','316251119','00371316251119');
  Test('00371316251119','316251119','00371316251119');

  NormalizeGreater:=5;                              // Singapure
  InternationalAreaCode:='+65';
  DialPrefix:='';
  InterNationalPrefixReplace:='018';
  NationalArea:='';
  NationalPrefix:='';

  ShowPrefixes;

  Test('+6529398545','29398545','0186529398545');
  Test('6646283197','6646283197','018656646283197');
  Test('(316)251119','316251119','01865316251119');
  Test('01865316251119','316251119','01865316251119');

  NormalizeGreater:=5;
  InternationalAreaCode:='+43';
  DialPrefix:='0';
  InterNationalPrefixReplace:='00';
  NationalArea:='316';
  nationalprefix:='9';

  ShowPrefixes;


  Test('+43316251119','0251119','00043316251119');
  Test('0043316251119','0251119','00043316251119');
  Test('+43(316)251119','0251119','00043316251119');
  Test('0043(316)251119','0251119','00043316251119');
  Test('+43(0316)251119','0251119','00043316251119');
  Test('0043(0316)251119','0251119','00043316251119');

  Test('+43317251119','09317251119','00043317251119');
  Test('0043317251119','09317251119','00043317251119');
  Test('43(0317)251119','09317251119','00043317251119');
  Test('43(317)251119','09317251119','00043317251119');
end;

begin
  TestSuite;
end.

