module Token
    syntax Value   ::= Int  // может быть изменено
    syntax Address ::= Int  // может быть изменено
    // определение синтаксисма контракта
    syntax AExp ::= Value | Address
                | "buy" "(" ")"
                | "balanceOf" "(" AExp ")"                       [strict]
                | "throw"
    // настройка ячеек хранилища контракта
    configuration <token>
                  <caller> 0 </caller>
                  <value> 0 </value>
                  <k> $PGM:K </k>
                  <accounts>
                    <account multiplicity="*">
                      <id> 0 </id>
                      <balance> 0 </balance>
                    </account>
                  </accounts>
                  <supply> 0 </supply>
                  <hardcap> Int 200 * (Int 10 ^Int 18) </hardcap>
                </token>
    // balanceOf возвращает баланс
    rule <k> balanceOf(Id) => Value ...</k>
       <id> Id </id>
       <balance> Value </balance>
    // Функция buy получает эфир и распределяет токены соответствующим образом.
    // Требования:
    // - функция buy должна получать эфир, поэтому значение не может быть нулевым
    // - после достижения жесткого лимита токены больше не могут быть проданы
    rule <k> buy() => .</k>
       <caller> From </caller>
       <value> MsgValue </value>
       <hardcap> HardCap </hardcap>
       <supply> Total => Total +Int MsgValue *Int 2</supply>
       <account>
         <id> From </id>
         <balance> BalanceFrom => BalanceFrom +Int MsgValue *Int 2 </balance>
       </account>
     requires MsgValue >=Int 0
       andBool Total +Int MsgValue *Int 2 <=Int HardCap
endmodule
